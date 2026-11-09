set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix5-20261104/egl-check.core
frame 4
set $dpy=dri2_dpy
set $scr=dri2_dpy->dri_screen_render_gpu
p $dpy->driver_name
p *$dpy->loader_extensions@4
p *$dpy->image_driver
p $dpy->dri2
x/24gx $scr
python
for off in (0x40,0x48,0x50,0x58,0x60):
    v=gdb.parse_and_eval('*(void **)((char *)$scr+%d)'%off)
    print('screen offset',hex(off),'value',str(v))
    if int(v):
        try: gdb.execute('p *(const __DRIextension *)%d'%int(v))
        except Exception as e: print(e)
end
p *dri2_surf
p *dri2_surf->base.Resource.Display
quit
