set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix5-20261104/egl-check.core
frame 4
set $dpy=dri2_dpy
set $disp=dri2_surf->base.Resource.Display
set $scr=dri2_dpy->dri_screen_render_gpu
p/x (unsigned long)&((_EGLDisplay *)0)->Platform
p/x (unsigned long)&((_EGLDisplay *)0)->PlatformDisplay
p/x (unsigned long)&((_EGLDisplay *)0)->DriverData
p/x $disp->Platform
p/x $disp->PlatformDisplay
printf "Vendor reads display at +0x30 and +0x38:\n"
p/x *(unsigned int *)((char *)$disp+0x30)
p/x *(void **)((char *)$disp+0x38)
printf "Stored display at screen +0x18; internal kind from screen +0x10:\n"
p/x *(void **)((char *)$scr+0x18)
p/x **(unsigned int **)((char *)$scr+0x10)
p/x *((void **)((char *)$scr+0x10))
x/8gx *((void **)((char *)$scr+0x10))
printf "Image lookup callback and image loader callbacks:\n"
p *(const __DRIimageLookupExtension *)*(void **)((char *)$scr+0x48)
p *(const __DRIimageLoaderExtension *)*(void **)((char *)$scr+0x60)
quit
