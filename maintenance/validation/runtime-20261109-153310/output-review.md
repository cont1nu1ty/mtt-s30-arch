# v10 exported output review

The input is `/var/tmp/mtt-s30-results-20261109-153310-46qtcw6l`, from hardware run `20261109-153310`. `check.py` performs read-only comparisons and writes only this review directory. Run it from any directory with `python3 /home/bull/Documents/mtt-s30-arch/work/v10-output-review-20261109/check.py`.

All three saved RGBA images match independently generated expected bytes. Vulkan frame 7 contains 12,288 pixels. EGL/GBM frame 7 and Wayland frame 59 each contain 49,152 pixels. The H.264 output contains 48 frames and 4,423,680 NV12 bytes. Every byte matches both the pinned CPU reference and a fresh software decode of the pinned H.264 clip using FFmpeg.

The native Wayland client reports `MTT S30` and `MOORE THREADS`. Its final successful result records 60 rendered frames, 2,949,120 pixel comparisons, 60 hardware presentations, zero mismatches and zero discards. The independent protocol parser matches all 60 presentation requests on surface 3 to their callbacks, including reuse of protocol object IDs. Every timestamp increases and all presentation flags equal 7. The first and last timestamps are 1,737,855,003,000 ns and 1,739,905,034,000 ns.

The final frame is followed by wl_buffer, DMA-BUF feedback, xdg_toplevel, xdg_surface, wl_surface and presentation destruction. The subsequent sync callback completes before the final JSON record. In the pinned client source, that record is reached only after successful EGL unbind, surface destruction, context destruction, EGL termination and Wayland cleanup. The recorded client exit is 0. KWin remains active on S30 and HDMI-A-1 at 1920×1080 after the client exits, then finishes via the requested SIGTERM with positive exit code 15 and no forced kill. The current compositor fault list is empty.

The exported manifest equals the packaged v10 manifest, SHA-256 `747d5896a604dd03bbae5b136082a635ad26bc7d0aa7d10275a3a487e9450304`. All eight local payloads match that manifest and the staged runner/source hashes match the exported configuration. The client's runtime library listing contains the private EGL and exactly the expected `desktop/client-dri/mtgpu_dri.so` and `desktop/client-dri/musa_dri.so`. The primary file's pinned hash is `05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23`. Root-stage bytes are covered by the runner's preflight checks and exported manifest, with runtime identity corroborated by the library paths.

The EGL log retains its initial PCI lookup warning with `driver (null)`, then selects and initializes the intended S30 paths. The recorded client reports successful completion and the earlier double-free message is absent.

Independent pixel comparison covers the saved final image for each render path. The earlier per-frame comparisons come from the pinned running test program. The output is client-framebuffer readback. No external HDMI scanout capture or sustained/full-desktop validation occurred in this run.
