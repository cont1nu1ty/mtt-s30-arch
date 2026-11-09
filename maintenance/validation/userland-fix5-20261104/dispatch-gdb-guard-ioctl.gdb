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
continue
echo UNEXPECTED_STOP_OR_RETURN\n
kill
quit 5
