# v7 KWin import review and v8 patch, 2026-11-04

The physical v7 round is **failed**. The log records a 1920×1080 XB24 image import failure immediately followed by a successful 1920×1080 XR24 normal/no-copy DRM-layer selection. No shadow success appears; the native client never ran. Keep the strict failure classification.

## Producer evidence

Source root: `work/kwin-format-context-final-20261104/kwin-6.8.2`.

- `src/backends/drm/drm_egl_layer.cpp:83` prepares the presentation test using the physical target dimensions and supported output formats.
- `src/backends/drm/drm_egl_layer_surface.cpp:312` → `checkSurface` → line 348 `createSurface`.
- Line 416 loops candidate formats; a failed candidate returns null and advances to the next format.
- Lines 450–475 intersect the selected format's modifiers with EGL render formats and reject an empty result before allocation.
- Line 489 allocates a normal same-device seed swapchain. `src/opengl/eglswapchain.cpp:187` allocates seed; its line 80 imports the seed as EGL texture and drops it on failure.
- Line 502 emits the selected DRM-layer marker only after seed image/FBO creation and the render test returned a framebuffer.
- `startRendering` line 83 first calls checkSurface; its shadow allocation at line 134 occurs only after that succeeds. Initial shadow creation therefore cannot precede the first successful parent-surface marker.

The equal dimensions and XB24→XR24 order strongly support a primary output candidate retry. This remains an inference because the failure line has no producer/attempt ID. Other import call sites cannot be categorically excluded from this log alone. `OutputLayer::filterAndSortFormats` (`src/core/outputlayer.cpp:254`) ties XR24/XB24 attributes; iteration/sort does not guarantee which is tried first.

## Repair

The current-query approach is insufficient because current S30 contexts can remain on secondary DRI. Independently re-read all 18 primary import table triples from pinned `mtgpu_dri.so` at file offset `0xc1c420`; exact bytes match the prior extraction. Intersecting the actual eight-format v7 current set with this table keeps six formats: R8, GR88, RG16, AR24, AB24, XR24; it removes XB24 and AB30. Dropping only XB24 leaves the same class of invalid format for AB30.

`patches/kwin-6.8.2-mtgpu-import-formats.patch` applies after v7's context patch. Only the existing S30/mtgpu branch narrows both maps, using a constexpr copy of those 18 entries after old/current intersection. No modifier is added, no external-only restriction is relaxed, and an empty result follows the existing rejection/cleanup. The raw current list stays visible; accepted becomes six. A separate fixed-driver-table marker records the exact vendor SHA and excluded formats. The marker changes to userland-fix7.

Table membership is a necessary condition, not proof of working import/render. The private recovery runner pins the exact official package; this is not generic MTT or later-driver support. Existing image/FBO/output/client/presentation/pixel validation and graphics error rejection remain required.

Dynamic allocation/import probing is broader: it needs a constructed shared context and allocator, cleanup, explicit expected-negative probe handling, and tuple-specific cache policy. One tiny successful buffer does not prove physical-sized buffers or other modifiers. The mandatory import-table rejection already supplies a smaller evidence-backed bound without adding hardware probes.

New regression requirements: replay the exact real eight formats including XB24/AB30; require six survivors; verify the constant table against pinned vendor bytes; preserve modifiers and external-only distinction; empty-after-table rejects; other drivers/models bypass; repeated refresh cannot reintroduce removed formats.

Only this work directory and the new independent patch were created; existing v7 source/builds/patch and vendor/system binaries are untouched. CPU compile evidence is in `compile-check/results.json` once complete.
