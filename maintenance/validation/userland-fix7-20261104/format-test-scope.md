# v8 format-regression evidence

This suite adds the physical v7 counterexample to the earlier 29 CPU cases.
There are 35 distinct candidate cases. Source mode and library mode execute the
same cases against different subjects; do not count those as 70 distinct cases.

`verified-inputs.json` records two independent inputs:

- the 18-entry primary DMA2 import table extracted from the hash-pinned official
  `mtgpu_dri.so` ELF at VA `0xc1c420`, resolving the file offset through ELF load
  segments (no ELF initialization, function call or GPU access);
- the archived `20261104-200750` hardware KWin capability trace, before=22 and
  current=8. The fixture keeps raw secondary format enumeration at 22, then
  rejects 14 current modifier queries to reproduce the observed 8-entry map.

The actual candidate EglDisplay method must produce exactly six format keys:
R8, GR88, RG16, AR24, AB24, XR24. XB24 and AB30 are both excluded. A separate
all-import-formats case supplies all 18 ELF-table entries plus XB24/AB30, so
omitting any legitimate table entry or adding a non-table entry fails without
copying the product's C++ table as the expected result.

The optional pinned-v7 baseline runs the **same new physical-counterexample
assertion** against the previous `libkwin` and must exit 42 with
`V7_REAL_FORMATS_REGRESSION`. This demonstrates that the new case catches the
real omission that the earlier 29 cases missed. That expected failure is a
negative control, not a passing candidate case.

All EGL/GL query callbacks and DRM identity are fixtures; no actual EGL context,
display server, GPU node or driver is initialized. Actual DMA-BUF import still
requires the recovery-gated physical round.

Initial patched-source evidence: `source-secondary-routing/results.json`.
Final source/library evidence: `final-source` / `final-library`, each 35/35 passed.
Both runs reject the pinned old v7 library with the same new case (exit 42).
