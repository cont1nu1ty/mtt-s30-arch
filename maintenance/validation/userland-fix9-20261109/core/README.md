# v9 native Wayland client core, 2026-11-09

The exported SIGABRT dump came from the root-owned native client in run 20261109-150112, PID 1179576. GDB used the tested executable, private Mesa EGL library and official driver. The exported compressed core SHA-256 is `a6f012ee99025cb13dcbc7eea5224dd3d23bb0d7ec4622c782a1553114a7b844`. The analyzed mtgpu_dri.so SHA-256 is `2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c`.

The native client reached main at egl-check.c:209. In the core, its counters are 60 hardware presentations, 0 discarded and an AND of feedback flags of 7. Its nonzero exit occurred during eglDestroySurface, after unbind. The saved last frame and protocol events can be checked independently. The application had yet to destroy its context or terminate EGL.

The backtrace in class.txt runs through private Mesa platform_wayland.c:840, mtgpu_dri.so+0x6e4380 (DRI core destroyDrawable), +0x5a7510 (calls slot 0 of the swap chain stored at internal drawable +0x38) and the allocator within +0x353980. The client log ends with glibc's double-free diagnostic. At +0x353a48 the second invocation of the base destructor attempts to deallocate the deque data pointer. The corresponding deque map and block have tcache keys in the core.

## Which destructor

The vendor's base destructor overwrites the object's vptr before the abort. The captured screen and factory arguments distinguish Wayland from a DRI2 class that also has doubled calls.

- The core records a NULL Kopper pointer and image_driver->createNewDrawable at mtgpu_dri.so+0x6ea0b0. destroyDrawable resolves to +0x6e4380. In the failing object's retained DRI drawable, wrapper->screen->platform has type 4, DRI2 loader NULL and a non-NULL image loader.
- Starting at +0x6ea0b0, internal type 4 at +0x6ea114 selects +0x6ea133 then calls +0x77c880 at +0x6ea2b0. The surviving object +0x10 holds the same native value as platform +0x10, the driver's cached native, and its Wayland sentinel, all 0x7f07cdeb8530. The recorded type cache contains 4. The type classifier at +0x6e8050 also returns 4 for that sentinel on a cache miss.
- The factory compares type 4 at +0x77c8a4, branches to +0x77cb90 and installs vtable +0x1070088 in the object at +0x77cbea. The Itanium RTTI names this class Ogl::Wsi::WaylandSwapChain. As a cross-check, alternate Ogl::Dri2::Dri2SwapChain constructor +0x6e9e90 sets object byte +0x234 to 1. It is 0 in the core.
- Complete Wayland destructor +0x5a5170 cleans up its derived allocation at +0x238, calls base Ogl::Sgl::SwapChain destructor +0x353980 at +0x5a51a0, restores the same object pointer, and tail-jumps to the same destructor at +0x5a51a9. The non-returning abort in the tail call thus unwinds directly to +0x5a7563.
- Deleting Wayland destructor +0x5875b0 has the same double call at +0x5875e0/+0x5875e8 and subsequently performs sized operator delete. This slot is independently identified in the ELF. This hardware run entered the complete destructor via slot 0.

A build-specific correction may remove the redundant first base call in each of these two Wayland entries while preserving all derived cleanup, the remaining base destructor, and sized delete in the deleting entry. The DRI2, GBM and DRI3 destructor targets are separate. The core covers the failure in v9. Corrected teardown through the normal DRM/Wayland integration still needs hardware measurement.

To repeat the core checks from the project root:

```sh
zstd -df /var/tmp/mtt-s30-results-20261109-150112/egl-check.core.zst -o work/v9-stack-review-20261109/client.core
gdb -nx -batch -x work/v9-stack-review-20261109/class.gdb builds/desktop-userland-fix8-20261106/egl-check
```
