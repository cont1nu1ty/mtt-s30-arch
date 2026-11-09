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
break *($base + 7230642)
commands
silent
echo UNEXPECTED_DEVICE_BRANCH\n
kill
quit 4
end
break *($base + 7233173)
commands
silent
echo UNEXPECTED_DEVICE_BRANCH\n
kill
quit 4
end
break *($base + 7233221)
commands
silent
echo UNEXPECTED_DEVICE_BRANCH\n
kill
quit 4
end
break *($base + 7233268)
commands
silent
echo UNEXPECTED_DEVICE_BRANCH\n
kill
quit 4
end
break *($base + 7231278)
commands
silent
printf "DISPATCH_TYPE=%u FD=%d\n", $edi, $esi
printf "STUB_DELEGATE_CALLS=%d\n", probe_delegate_calls
echo STOPPED_BEFORE_DEVICE_WORK\n
kill
quit 0
end
continue
echo UNEXPECTED_STOP_OR_RETURN\n
kill
quit 5
