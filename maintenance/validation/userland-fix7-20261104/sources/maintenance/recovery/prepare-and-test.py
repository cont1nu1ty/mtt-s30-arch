#!/usr/bin/env python3
"""Create a fresh verified backup, then launch the reviewed one-shot GPU test.

This is the explicit disruptive entry point: it stops the desktop and reboots.
It never reuses an old test directory or installs a persistent driver.
"""
import importlib.util
import os
from pathlib import Path
import sys


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(filename))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def launch(prepare, runner, workloads=False, desktop=False):
    # Catch a rolling desktop-stack upgrade before making another EFI backup.
    # The privileged runner rechecks after staging and before stopping KDE.
    if desktop:
        runner.desktop_support.verify_host()
    # Use only the path returned by this successful preflight, never glob for
    # the latest backup or fall back to a previous successful attempt.
    backup = prepare.main()
    if not isinstance(backup, Path):
        raise RuntimeError('Preflight did not return a fresh backup path.')
    if desktop:
        runner.start(backup, desktop=True)
    elif workloads:
        runner.start(backup, workloads=True)
    else:
        runner.start(backup)
    return backup


def main():
    if sys.argv[1:] not in (['--start'], ['--start', '--workloads'], ['--start', '--desktop']):
        raise RuntimeError('Usage: sudo python3 prepare-and-test.py --start [--workloads|--desktop] (stops KDE and reboots)')
    if os.geteuid() != 0:
        raise RuntimeError('Run with sudo in your own terminal; never send a password to chat.')
    print('Creating a NEW recovery backup, then starting the temporary GPU test.', flush=True)
    print('After checks pass, KDE will stop; a reboot is planned. Save all work before running this command.', flush=True)
    launch(load('mtt_preflight', 'prepare-recovery.py'), load('mtt_runner', 'test-once.py'),
           workloads='--workloads' in sys.argv, desktop='--desktop' in sys.argv)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print('STOP: ' + str(e), file=sys.stderr)
        sys.exit(1)
