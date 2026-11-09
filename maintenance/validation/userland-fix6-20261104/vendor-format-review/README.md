# Official 3.1.0 DMA-BUF format consistency review, 2026-11-04

The latest `20261104-152912` round logged a **1920x1080 XB24** DMA-BUF import error with implicit modifier, one plane, stride 7680, offset 0. This review identifies a specific inconsistency in the pinned vendor userspace, independent of that single runtime error. It does not claim all hardware paths or all future driver versions reject XB24.

## Evidence

1. `mtgpu_dri.so` DRI_IMAGE v20 `queryDmaBufFormats` is at ELF VA `0x6e2450`. Its primary table at `0xc1c420` has 18 formats and **does not include XB24**. It includes AR24, AB24, XR24.
2. The query chooses its primary table when its TLS slot +8 is non-null. The slot is proven to represent the primary current GL context: DRI_Core `bindContext` at `0x6e3970` stores context+0x20 there at instruction `0x6e39eb`; `unbindContext` at `0x6e38e0` clears it at `0x6e3936`.
3. Without that current context, and when the secondary DRI_IMAGE delegate exists, the query delegates via callback +0xa0 and secondary screen +0xb0. That path reaches `musa_dri.so+0xc150 -> +0xb3a0 -> libmusa_dri_support.so+0x15740`.
4. The secondary table has XB24 as a visible format. The historical **20261104-112910 client** core has all 31 secondary format-mask entries enabled. Replaying the actual secondary query instruction bytes with that mask returns 22 formats, including AR24, AB24, XR24, XB24. The latest KWin screen/mask itself has not been read, so that last correspondence remains an inference for the new round.
5. `createImageFromDmaBufs2` at `0x711c90` scans the same 18-entry primary table at `0x712080` for every nonzero fourcc. A miss returns NULL and DRI error **3 / BAD_PARAMETER** at `0x712120`. The format scan occurs before the fd/device import helper (call at `0x711f47`) and before any TLS/secondary delegation. Thus XB24 cannot reach that import helper through this particular callback; changing current context cannot rescue its missing table entry. The callback does perform an internal 8-byte allocation before these checks; no whole import callback was run here.
6. The primary `queryDmaBufModifiers` at `0x6e2520` uses a **different** format table, recognizes XB24, and reports supported modifiers. The GBM backend `is_format_supported` at `0x1680` maps XB24 to DRI format 0x1005 and relies on that modifier callback. Its pure CPU execution consequently reports XB24 supported despite item 5.

These are sufficient reasons to re-query and narrow KWin's cached format list **after its rendering context is current**, scoped to the affected vendor. A hardcoded global XB24 blacklist is unnecessary. A candidate in the surviving set still requires actual device import/render testing.

## Pure CPU probe

`pure-format-probe.c` maps unmodified ELF bytes as read/execute, without `dlopen`, ELF constructors, any EGL initialization, any context creation, or a device fd. It executes:

- the primary format query body after its TLS branch, via a wrapper that recreates its existing stack/register prologue;
- the complete primary modifier callback with minimal memory structures (native kinds 0 and 4; kind 8 uses device-global state and is deliberately not executed);
- the secondary query callback with the historical 31-entry mask;
- the GBM format support callback with the real primary modifier callback and minimal memory structures.

A seccomp guard forbids open/openat/openat2, ioctl, sockets/connect, and io_uring before any mapped instruction is called. Binary hashes are pinned by `run-probes.py`. All results are stored in `pure-format-probe.json`; `review.json` includes decoded tables, hashes, and evidence boundaries. Callback addresses came from the historical core's DRI extension tables and were checked against current vendor file bytes.

For the 18 primary formats, modifiers succeed only for R8, GR88, AR24, AB24, XR24, XR30, RG16. Native kind 4 yields LINEAR/external_only=false. Kind 0 yields LINEAR/external_only=false plus `0x9200000000000015`/external_only=true. The other 11 formats return false **without writing the count**. XB24, although absent from the primary enumeration, also succeeds in the modifier query and GBM check.

Therefore, a strict follow-up query must not reject the entire GPU merely because one enumerated format's modifier query fails. It can drop uncertain formats and intersect successful formats/modifiers with the prior capability set. An empty surviving set or failed format enumeration must fail closed.

Run from the repository root:

```sh
python3 work/s30-format-review-20261104/run-probes.py
```

No vendor binary, kernel module, desktop session, boot file, or automatic load configuration was modified by this review.
