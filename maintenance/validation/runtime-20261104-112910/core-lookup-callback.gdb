set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix4-20261104/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix5-20261104/egl-check.core
python
import struct
base=0x7fcf43a00000
mem=bytes(gdb.selected_inferior().read_memory(base+0x281d00,0x500))
for off in range(0,len(mem),8):
    val=struct.unpack_from('<Q',mem,off)[0]
    if val == 0x7fcf4b200000+0xa910:
        print('SUPPORT_LOOKUP_CALLBACK_OFFSET='+hex(0x281d00+off))
end
quit
