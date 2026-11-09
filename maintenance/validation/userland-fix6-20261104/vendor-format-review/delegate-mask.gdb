set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix5-20261104/egl-check.core
frame 4
set $base = (char*)0x7fcf4b600000
set $delegate = *(__DRIimageExtension**)($base+0x1102c70)
p/x dri2_dpy->dri_screen_render_gpu
set $musa_screen = *(char**)((char*)dri2_dpy->dri_screen_render_gpu+0xb0)
set $musa_native = *(char**)($musa_screen+0x10)
set $support_screen = *(char**)($musa_native+8)
p/x $support_screen
p *(int*)($support_screen+0x20)
p/x *(void**)($support_screen+0x28)
x/31ub *(void**)($support_screen+0x28)
dump binary memory /home/bull/Documents/mtt-s30-arch/work/s30-format-review-20261104/historical-musa-format-mask.bin *(char**)($support_screen+0x28) *(char**)($support_screen+0x28)+31
quit
