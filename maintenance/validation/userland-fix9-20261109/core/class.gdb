set debuginfod enabled off
set auto-load safe-path /nonexistent
set solib-search-path official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:official/driver-3.1.0/usr/lib/x86_64-linux-gnu:builds/desktop-userland-fix8-20261106/egl
core-file work/v9-stack-review-20261109/client.core
bt
frame 9
set $s=(struct dri2_egl_surface*)surf
set $e=(struct dri2_egl_display*)$s->base.Resource.Display->DriverData
p/x $e->image_driver
p/x $e->image_driver->createNewDrawable
p/x $e->kopper
p/x $e->core->destroyDrawable
frame 6
set $base=$pc-0x353a4d
set $sw=$rbx
set $wrapper=*(void**)($sw+0x1c8)
set $screen=*(void**)($wrapper+0x18)
set $platform=*(void**)($screen+0x10)
printf "wrap/screen/platform %p %p %p; platform type %d\n",$wrapper,$screen,$platform,*(int*)$platform
printf "screen dri2Loader ptr %p imageLoader ptr %p; swapchain +16 %p = platform+16 %p\n", *(void**)($screen+0x40), *(void**)($screen+0x60),*(void**)($sw+0x10), *(void**)($platform+0x10)
printf "vendor cached native %p type %u; Wayland sentinel %p\n",*(void**)($base+0x10c3790), *(unsigned*)($base+0x10b6614), *(void**)($base+0x10c5df8)
printf "constructor discriminator +234 byte %d (alternate Dri2 constructor writes 1), +238 qword %p, current vptr offset %#lx\n", *(unsigned char*)($sw+0x234), *(void**)($sw+0x238), *(void**)$sw-(void*)$base
printf "Dri2 / Wayland name pointers via vtable RTTI\n"
x/s *(void**)(*(void**)($base+0x105e7d8-8)+8)
x/s *(void**)(*(void**)($base+0x1070088-8)+8)
frame 11
printf "checker globals after completing its pixel loop and saving the output: presented=%d discarded=%d hardware_presentations=%u flags_all=%u\n", presented,discarded,hardware_presentations,flags_all
