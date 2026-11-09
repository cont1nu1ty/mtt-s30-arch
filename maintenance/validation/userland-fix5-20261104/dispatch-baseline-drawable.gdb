set pagination off
set confirm off
set auto-load off
set debuginfod enabled off
set disable-randomization off
handle SIGSYS stop print nopass
break probe_ready
run
printf "GUARD=%d\n", probe_guard_enabled
set $base = vendor_base
catch syscall ioctl open openat openat2 socket socketpair connect io_uring_setup io_uring_enter
commands
silent
echo FORBIDDEN_SYSCALL\n
kill
quit 3
end
break *($base + 7250227)
commands
silent
echo DRAWABLE_BRANCH=image\n
printf "STUB_DELEGATE_CALLS=%d\n", probe_delegate_calls
echo STOPPED_BEFORE_DEVICE_WORK\n
kill
quit 0
end
break *($base + 7250672)
commands
silent
echo DRAWABLE_BRANCH=xcb\n
printf "STUB_DELEGATE_CALLS=%d\n", probe_delegate_calls
echo STOPPED_BEFORE_DEVICE_WORK\n
kill
quit 0
end
continue
echo UNEXPECTED_STOP_OR_RETURN\n
kill
quit 5
