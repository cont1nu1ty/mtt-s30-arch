set confirm off
set pagination off
break probe_ready
run
set $creator=(char *)screen_creator
break *($creator+0x148)
break *($creator+0x44f)
continue
python
pc=int(gdb.parse_and_eval('$pc'));base=int(gdb.parse_and_eval('$creator'))
print('LOOKUP_GATE_OFFSET='+hex(pc-base))
assert pc-base == 0x44f
end
quit
