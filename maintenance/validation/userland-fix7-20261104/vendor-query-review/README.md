# v7 EGL/DRI format query correction, 2026-11-04

The `20261104-200750` hardware log disproves the assumption that making an EGL context current necessarily selects mtgpu's primary format query. The new intersection code ran, but its logged current map still contained XB24. This is a limitation of the original fix's premise, not evidence that the callback hook was skipped.

## What the actual binary does

- Official `libEGL_mtgpu.so.0.0.0` SHA256: `0a9460529f715037c0db589cefc5fd864e2915c7b373cc0f37b32ec70a0500b3`.
- Official `mtgpu_dri.so` SHA256: `2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c`.
- EGL's public query implementation at VA `0x16c50` calls the driver vtable slot `+0x168` at `0x16d48`. The matching relocation is vtable `0x24d3e8 -> 0x31010`.
- That driver query wrapper at `0x31010` obtains the image extension from private display `+0x68`, obtains `queryDmaBufFormats` from image extension `+0xa0`, and calls it at `0x31070` with screen pointer from private display `+0x10`. **There is no format-result cache in this wrapper.**
- mtgpu `queryDmaBufFormats@0x6e2450` chooses its primary 18-entry table only if primary TLS `+8` is non-null, or no secondary image extension is available. Otherwise `0x6e24ec..0x6e250c` calls secondary `queryDmaBufFormats` with screen `+0xb0`.
- The previous analysis only described the primary half of `bindContext@0x6e3970`. Its first branch reads context `+0x30`: if non-null, `0x6e397e..0x6e39ba` invokes secondary core `bindContext` at slot `+0x68` and returns **without touching primary TLS**. Secondary unbind similarly uses core slot `+0x70` at `0x6e38fb..0x6e390a` without clearing/writing primary TLS. Thus an EGL-current secondary context can coexist with null primary TLS.

The latest KWin private context/TLS was not captured. The secondary route is the explanation supported by the binary and the exact runtime format set, rather than a direct read of that live private field.

## Original-instruction CPU replay

`run-probe.py` pins the three vendor files, compiles `egl-query-probe.c`, and maps PT_LOAD segments without `dlopen`, ELF constructors or driver initialization. Code bytes remain unchanged. Only the fake image's GOT/global data references for the TLS resolver and downstream secondary bind/unbind point to bounded test fixtures. A seccomp guard forbids opens, device ioctls, sockets/connect and io_uring before executing the mapped code. There is no actual EGL context, real TLS, GPU node or display server.

The replay executes the original EGL driver query wrapper, full mtgpu format query, original secondary musa query, original primary modifier query, and original secondary-bind/unbind branches. Results:

1. EGL wrapper query returns 22 secondary formats.
2. Secondary bind calls the downstream bind fixture and neither invokes the TLS resolver nor changes primary TLS. The subsequent query remains the same 22 formats.
3. Applying actual primary modifier queries to those 22 values yields exactly the **8 formats in the new hardware `current` diagnostic**: AB30, AR24, AB24, XR24, XB24, RG16, GR88, R8.
4. Setting only synthetic primary TLS to non-null causes the same original EGL wrapper to return 18 primary formats; clearing the fixture returns 22 again. This `22 -> 18 -> 22` result rules out caching in the tested wrapper.
5. Secondary unbind also does not invoke the primary TLS resolver or change its value.

The 31-entry secondary mask is the already preserved historical `20261104-112910` client mask. Its 22-item result exactly equals the latest hardware `before` list. The modifier fixture uses native kind 4. These are controlled fixtures, not direct observations of the latest KWin's private screen.

KWin's v7 `current QList(...)` logs its post-modifier-query map, **not the raw result of eglQueryDmaBufFormatsEXT**. Its reduction from 22 to 8 therefore does not show that the raw format enumeration changed: rejecting failed modifier queries alone reproduces the reduction.

## Import table and narrow repair boundary

`import-format-table.json` and `.bin` contain the exact original table at ELF VA and file offset `0xc1c420`, **18 entries, stride 12 bytes**, table SHA256 `b4663bd6b57237893a6aeb9b117767074adab2e6a3b515535c175511cdee4995`:

```
R8   GR88 R16  GR32 RA24 AR24 AB24 XR24 XR30 RG16 AYUV P010 P016 UYVY VYUY NV12 NV21 YV12
```

The same table is used by the DMA-BUF import callback `createImageFromDmaBufs2@0x711c90`. Its format scan at `0x712080` advances by 12 bytes and compares 18 entries; a miss reaches `0x712120`, writes DRI error 3, and returns NULL before the fd import helper and secondary delegation.

A narrowly scoped repair can intersect the reported format/modifier maps with this pinned binary's import table, preserving modifiers and external-only classifications. Against the new 8-item runtime set, the result is **AB24, AR24, GR88, R8, RG16, XR24**; it removes **AB30 and XB24**. This is based on the actual import guard, not an assumption about which GL implementation becomes current. The newly logged XR24 main-output allocation succeeded in the same hardware round, while prior XB24 allocation failed.

Scope this quirk to the isolated, SHA-pinned official 3.1.0 mtgpu/S30 stack. Keep input hashes, private executable/library identity, no persistent installation, and all image/kernel fault checks. Do not apply the table as a universal future mtgpu capability claim or add formats absent from the runtime query. Table membership is only a necessary import check; the next device test must still establish actual DMA-BUF import, rendering, presentation and pixel correctness.

To replay from the project root:

```sh
python3 work/v7-vendor-query-20261104/run-probe.py
```

No production source, patch, vendor binary, boot file or driver state was modified by this analysis.
