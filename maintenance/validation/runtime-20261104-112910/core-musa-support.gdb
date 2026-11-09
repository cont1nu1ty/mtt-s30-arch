set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix5-20261104/egl-check.core
set $musa=0x7fcf4b200000
p/x *(void **)($musa+0x240f00)
x/16i *(void **)($musa+0x240f00)
quit
