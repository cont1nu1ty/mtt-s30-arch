set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix5-20261104/egl-check.core
set $vendor=0x7fcf4b600000
p *(const __DRIimageDriverExtension *)*(void **)($vendor+0x1102c48)
frame 4
set $scr=dri2_dpy->dri_screen_render_gpu
x/32gx *(void **)((char *)$scr+0xb0)
quit
