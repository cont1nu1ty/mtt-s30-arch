"""Bound a private desktop process group without touching the user's session.

Callers must keep KWin, Plasma, XWayland and their helpers in this group; the
outer launcher is its only setsid boundary. Hardware runs also retain the
supervisor's systemd control group and independent reboot deadlines.
"""
import os
from pathlib import Path
import signal
import subprocess
import time


class SessionTimeoutExpired(subprocess.TimeoutExpired):
    def __init__(self, cmd, timeout, remaining):
        super().__init__(cmd, timeout)
        self.remaining = remaining

    def __str__(self):
        return super().__str__() + '; live session processes after cleanup: ' + repr(self.remaining)


def live_group_members(pgid):
    """Ignore reparented zombies: they cannot run or retain GPU descriptors."""
    members = []
    for path in Path('/proc').iterdir():
        if not path.name.isdecimal():
            continue
        try:
            # comm can contain spaces and parentheses; the last ')' ends it.
            fields = (path / 'stat').read_text().rsplit(')', 1)[1].split()
            if int(fields[2]) == pgid and fields[0] not in ('Z', 'X'):
                members.append(int(path.name))
        except (FileNotFoundError, ProcessLookupError):
            pass
    return members


def _signal_group(pgid, sig):
    try:
        os.killpg(pgid, sig)
    except ProcessLookupError:
        pass


def _wait_empty(pgid, seconds):
    end = time.monotonic() + seconds
    while live_group_members(pgid):
        if time.monotonic() >= end:
            return False
        time.sleep(min(0.05, max(0, end - time.monotonic())))
    return True


def _cleanup(proc):
    _signal_group(proc.pid, signal.SIGTERM)
    if not _wait_empty(proc.pid, 2):
        _signal_group(proc.pid, signal.SIGKILL)
        _wait_empty(proc.pid, 1)
    try:
        proc.wait(timeout=1)
    except subprocess.TimeoutExpired:
        # A task blocked in the kernel can remain unkillable. Do not turn a
        # bounded desktop failure into an unbounded wait or disarm recovery.
        pass
    return live_group_members(proc.pid)


def run_session(args, *, timeout, stdout=None, stderr=None, env=None):
    """Like subprocess.run for file-backed output, with whole-group cleanup.

    A timeout remains TimeoutExpired after cleanup. A successful leader that
    leaves live children is an error, even if those children can be killed.
    """
    proc = subprocess.Popen(args, stdout=stdout, stderr=stderr, env=env,
                            start_new_session=True)
    try:
        code = proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired as error:
        remaining = _cleanup(proc)
        raise SessionTimeoutExpired(error.cmd, error.timeout, remaining) from error
    except BaseException as error:
        remaining = _cleanup(proc)
        if remaining:
            error.add_note('Private session still has live processes: ' + repr(remaining) +
                           '; the armed recovery supervisor must reboot.')
        raise
    if not _wait_empty(proc.pid, 0.5):
        leftover = live_group_members(proc.pid)
        remaining = _cleanup(proc)
        raise RuntimeError('Private session left live child processes after leader exit: ' + repr(leftover) + '; '
                           'remaining after cleanup: ' + repr(remaining))
    return subprocess.CompletedProcess(args, code)
