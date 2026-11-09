set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix2-20261103/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix2-20261103/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix3-20261103/egl-check.core
bt
info registers rax rbx rcx rdx rdi rsi r8 r9 rip
frame 1
info locals
set $dpy = dri2_dpy
printf "\nDRIVER NAME AND OPAQUE SCREEN\n"
p $dpy->driver_name
p $dpy->dri_screen_render_gpu
printf "\nVENDOR GETAPIMASK RESULT AS ESTABLISHED BY DISASSEMBLY (SCREEN+0xa0)\n"
p/x *(unsigned int *)((char *)$dpy->dri_screen_render_gpu + 0xa0)
printf "\nDRI MESA AND IMAGE DRIVER TABLES\n"
p *$dpy->mesa
p *$dpy->image_driver
printf "\nCORE AND IMAGE EXTENSIONS\n"
p *$dpy->core
p *$dpy->image
printf "\nFENCE, FLUSH, CONFIG AND DAMAGE EXTENSIONS\n"
p *$dpy->fence
p *$dpy->flush
p *$dpy->config
p *$dpy->buffer_damage
printf "\nIMAGE DRIVER CONTEXT CALLBACK FIRST INSTRUCTIONS (NO EXECUTION)\n"
x/12i $dpy->image_driver->createContextAttribs
printf "\nPUBLIC GETAPIMASK CALLBACK (NO EXECUTION)\n"
x/3i $dpy->image_driver->getAPIMask
printf "\nLOADER EXTENSIONS\n"
p $dpy->loader_extensions
p *$dpy->loader_extensions@5
quit
