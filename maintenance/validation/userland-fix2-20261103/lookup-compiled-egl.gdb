set confirm off
set pagination off
break probe_ready
run
python
assert int(gdb.parse_and_eval('mtgpu_image_lookup_v1.base.version')) == 1
assert int(gdb.parse_and_eval('mtgpu_image_lookup_v1.lookupEGLImage')) == int(gdb.parse_and_eval('&dri2_lookup_egl_image'))
assert int(gdb.parse_and_eval('mtgpu_image_lookup_v1.validateEGLImage')) == 0
assert int(gdb.parse_and_eval('mtgpu_image_lookup_v1.lookupEGLImageValidated')) == 0
print('COMPILED_EGL_V1_TABLE_AND_VALIDATING_CALLBACK_VERIFIED')
end
up
set variable extensions[0] = (const struct ext *)&mtgpu_image_lookup_v1
down
set $creator=(char *)screen_creator
break *($creator+0x148)
break *($creator+0x44f)
continue
python
pc=int(gdb.parse_and_eval('$pc'));base=int(gdb.parse_and_eval('$creator'))
print('LOOKUP_GATE_OFFSET='+hex(pc-base))
assert pc-base == 0x148
end
quit
