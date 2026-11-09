set auto-load off
set debuginfod enabled off
set pagination off
set print pretty on
set solib-search-path /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix3-v3-20261103/egl:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri:/home/bull/Documents/mtt-s30-arch/official/driver-3.1.0/usr/lib/x86_64-linux-gnu:/usr/lib
file /home/bull/Documents/mtt-s30-arch/builds/desktop-userland-fix3-v3-20261103/egl-check
core-file /home/bull/Documents/mtt-s30-arch/work/userland-fix4-20261104/egl-check.core
bt
frame 7
info locals
printf "\nACTUAL INVALID KEY READ OUTSIDE ATTRIBUTE MAP\n"
p/x *((int *)dri2_to_egl_attribute_map + attrib)
printf "\nFIRST DRIVER CONFIG VS CURRENT CONFIG\n"
p dri2_dpy->driver_configs[0]
p dri_config
set $config=(char *)dri_config
dump binary memory /home/bull/Documents/mtt-s30-arch/work/userland-fix4-20261104/actual-first-config.bin $config $config+0x100
printf "\nDIRECT PUBLIC GETTERS\n"
p dri2_dpy->core->indexConfigAttrib
p dri2_dpy->core->getConfigAttrib
python
import gdb, json
from pathlib import Path
base=Path('/home/bull/Documents/mtt-s30-arch/work/userland-fix4-20261104')
dpy=gdb.parse_and_eval('dri2_dpy')
rows=[]
for i in range(4096):
    pointer=dpy['driver_configs'][i]
    if int(pointer)==0: break
    rows.append({'index':i,'original_pointer':hex(int(pointer)),'bytes':gdb.selected_inferior().read_memory(pointer,0xd4).tobytes().hex()})
else: raise Exception('Config enumeration bound exceeded')
(base/'actual-configs.json').write_text(json.dumps({'run':'20261104-111130','first_config_bytes':256,'vendor_allocation_bytes':212,'config_count':len(rows),'configs':rows},indent=2)+'\n')
print('CONFIG_COUNT='+str(len(rows)))
end
quit
