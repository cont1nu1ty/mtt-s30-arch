#!/usr/bin/env python3
"""Copy bounded test logs for the invoking user; never load or unload modules."""
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import time
import uuid

spec = importlib.util.spec_from_file_location('runner', Path(__file__).with_name('test-once.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


CORE_DIRECTORY = Path('/var/lib/systemd/coredump')
CORE_LIMIT = 256 * 1024 * 1024
CORE_SIGNALS = ('6', '11')  # SIGABRT and SIGSEGV only.
CORE_CLIENTS = ('egl-check', 'qt-check', 'x11-check')
SYSTEM_CORE_CLIENTS = {
    'plasmashell': ('/usr/bin/plasmashell', 'plasma-result.json', ('shell_pid',)),
    'Xwayland': ('/usr/bin/Xwayland', 'xwayland-result.json', ('server', 'pid')),
}


def recorded_system_pid(stage, client):
    """A fixed system executable also needs this run's root-owned PID record."""
    executable, filename, keys = SYSTEM_CORE_CLIENTS[client]
    try:
        fd = os.open(Path(stage) / filename, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    except FileNotFoundError:
        return None
    with os.fdopen(fd, 'rb') as stream:
        info = os.fstat(stream.fileno())
        m.check(stat.S_ISREG(info.st_mode) and info.st_uid == 0 and not info.st_mode & 0o022
                and 0 < info.st_size <= 65536, 'Unsafe system-client PID record.')
        data = stream.read(65537)
        m.check(len(data) <= 65536, 'System-client PID record exceeds bound.')
        value = json.loads(data)
    for key in keys:
        if not isinstance(value, dict) or key not in value:
            return None
        value = value[key]
    m.check(type(value) is int and 0 < value < 2 ** 31, 'Invalid system-client PID.')
    return str(value)


def core_identity(stage, client, expected_pid=None):
    if client in CORE_CLIENTS:
        m.check(expected_pid is None, 'Unexpected PID override for staged client.')
        return str(Path(stage) / 'desktop' / client)
    m.check(client in SYSTEM_CORE_CLIENTS, 'Unexpected core client.')
    m.check(isinstance(expected_pid, str) and expected_pid.isascii() and expected_pid.isdigit()
            and 0 < int(expected_pid) < 2 ** 31, 'System-client exact PID is required.')
    return SYSTEM_CORE_CLIENTS[client][0]


def copy_client_core(record, stage, boot_id, out, client='egl-check', expected_pid=None):
    """Copy only the journal-identified isolated client's core, without decoding it."""
    executable = core_identity(stage, client, expected_pid)
    boot = uuid.UUID(boot_id).hex
    expected = {'_BOOT_ID': boot, 'COREDUMP_EXE': executable,
                'COREDUMP_UNIT': 'mtt-s30-once.service',
                'COREDUMP_UID': '0'}
    if expected_pid is not None:
        expected['COREDUMP_PID'] = expected_pid
    m.check(all(record.get(k) == v for k, v in expected.items()),
            'Core metadata does not identify this test client.')
    m.check(record.get('COREDUMP_SIGNAL') in CORE_SIGNALS,
            'Core signal is not an allowed client crash.')
    pid, timestamp = record.get('COREDUMP_PID', ''), record.get('COREDUMP_TIMESTAMP', '')
    m.check(isinstance(pid, str) and pid.isascii() and pid.isdigit() and int(pid) > 0
            and isinstance(timestamp, str) and timestamp.isascii() and timestamp.isdigit(),
            'Invalid core process identity.')
    source = Path(record.get('COREDUMP_FILENAME', ''))
    prefix = f'core.{client}.0.{boot}.{pid}.{timestamp}'
    suffix = source.name[len(prefix):] if source.name.startswith(prefix) else None
    m.check(source.parent == CORE_DIRECTORY and suffix in ('', '.zst', '.lz4', '.xz'),
            'Unexpected core storage path.')
    destination = out / (client + '.core' + suffix)
    directory_fd = os.open(CORE_DIRECTORY, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        ds = os.fstat(directory_fd)
        m.check(ds.st_uid == 0 and not ds.st_mode & 0o022, 'Unsafe core directory.')
        fd = os.open(source.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
                     dir_fd=directory_fd)
        with os.fdopen(fd, 'rb') as src:
            before = os.fstat(src.fileno())
            m.check(stat.S_ISREG(before.st_mode) and before.st_uid == 0
                    and not before.st_mode & 0o022, 'Unsafe core file.')
            m.check(0 < before.st_size <= CORE_LIMIT, 'Core exceeds bounded export size.')
            start = time.monotonic()
            remaining = before.st_size
            created = False
            try:
                with destination.open('xb') as target:
                    created = True
                    while remaining:
                        m.check(time.monotonic() - start < 10, 'Core copy deadline exceeded.')
                        block = src.read(min(1024 * 1024, remaining))
                        m.check(bool(block), 'Core changed during copy.')
                        target.write(block)
                        remaining -= len(block)
                    after = os.fstat(src.fileno())
                    m.check((before.st_size, before.st_mtime_ns, before.st_ctime_ns) ==
                            (after.st_size, after.st_mtime_ns, after.st_ctime_ns),
                            'Core changed during copy.')
            except Exception:
                # Output directory is newly created and root-only until export ends.
                if created:
                    destination.unlink()
                raise
    finally:
        os.close(directory_fd)
    return {'status': 'copied', 'name': destination.name, 'source_bytes': before.st_size,
            'sha256': m.sha(destination), 'pid': pid, 'boot_id': boot,
            'signal': record['COREDUMP_SIGNAL'],
            'format': suffix.lstrip('.') or 'uncompressed',
            'scope': f'Only the isolated test {client} process; compressed core copied unchanged.'}


def export_client_core(stage, boot_id, out, client='egl-check'):
    """Missing/expired crash evidence must not change the independent EFI verdict."""
    if not boot_id:
        return {'status': 'unavailable', 'reason': 'No test boot ID.'}
    fields = ('_BOOT_ID', 'COREDUMP_EXE', 'COREDUMP_UNIT', 'COREDUMP_SIGNAL',
              'COREDUMP_UID', 'COREDUMP_PID', 'COREDUMP_TIMESTAMP', 'COREDUMP_FILENAME')
    try:
        expected_pid = None
        if client in SYSTEM_CORE_CLIENTS:
            expected_pid = recorded_system_pid(stage, client)
            if expected_pid is None:
                return {'status': 'skipped', 'reason': 'No exact system-client PID recorded for this test.'}
        executable = core_identity(stage, client, expected_pid)
        result = subprocess.run(
            ['journalctl', '--boot=' + uuid.UUID(boot_id).hex, '--no-pager', '-n', '2',
             '-o', 'json', '--output-fields=' + ','.join(fields),
             'COREDUMP_EXE=' + executable,
             'COREDUMP_UNIT=mtt-s30-once.service', 'COREDUMP_UID=0',
             *(['COREDUMP_PID=' + expected_pid] if expected_pid is not None else []),
             # journalctl ORs matches of the same field, while retaining the
             # AND with executable, unit, UID and boot restrictions.
             *('COREDUMP_SIGNAL=' + signal for signal in CORE_SIGNALS)],
            capture_output=True, text=True, timeout=15, env=m.ENV)
        m.check(result.returncode == 0, 'Core journal query failed.')
        m.check(len(result.stdout) <= 65536, 'Core metadata exceeds export bound.')
        rows = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
        if not rows:
            return {'status': 'not_found', 'reason': 'No matching client SIGABRT/SIGSEGV in test boot.'}
        m.check(len(rows) == 1, 'Ambiguous client core records; no core exported.')
        return copy_client_core(rows[0], stage, boot_id, out, client, expected_pid)
    except Exception as e:
        return {'status': 'unavailable', 'reason': str(e)}


def main():
    m.check(os.geteuid() == 0 and len(sys.argv) == 2,
            'Usage: sudo python3 collect-results.py /var/lib/mtt-s30-test/TIMESTAMP')
    uid, gid = int(os.environ.get('SUDO_UID', '0')), int(os.environ.get('SUDO_GID', '0'))
    m.check(uid > 0 and gid > 0, 'Run with sudo as your normal desktop user.')
    backup = Path(sys.argv[1]).resolve()
    m.check(backup.parent == Path('/var/lib/mtt-s30-test'), 'Unexpected backup path.')
    s = backup.stat()
    m.check(s.st_uid == 0 and not s.st_mode & 0o022, 'Unsafe backup permissions.')
    stage = backup / 'test'
    current_boot = Path('/proc/sys/kernel/random/boot_id').read_text().strip()
    result_path = stage / 'supervisor-result.json'
    previous = json.loads(result_path.read_text()) if result_path.exists() else {}
    m.check(previous.get('boot_id') != current_boot,
            'Test was started in this boot; wait for the planned reboot before collecting.')
    out = Path('/var/tmp') / ('mtt-s30-results-' + backup.name)
    try:
        out.mkdir(mode=0o700)
    except FileExistsError:
        out = Path(tempfile.mkdtemp(prefix=out.name + '-', dir=out.parent))
    copied = []
    for name in ('supervisor-result.json', 'probe-result.json', 'config.json',
                 'kernel-live.log', 'kernel-before.log', 'kernel-check.log', 'kernel-final.log',
                 'probe.log', 'stop-desktop.log', 'protect-esp.log', 'dependencies.log',
                 'insmod.log', 'iomem-after.log', 'pci-resources.log',
                 'mthreads-gmi.log', 'vulkan.log', 'vaapi.log',
                 'render-workload.log', 'video-workload.log', 'render.rgba',
                 'decoded.nv12', 'workload-result.json', 'workload-manifest.json',
                 'desktop-manifest.json', 'egl-gbm.log', 'egl-gbm.rgba',
                 'kwin-session.log', 'kwin.log', 'kwin-support-before.log', 'kwin-support-after.log',
                 'wayland-client.log', 'wayland.rgba', 'kwin-kernel-check.log',
                 'qt-client.log', 'qt.rgba', 'qt.rgba.png',
                 'plasma.log', 'plasma-activities.log', 'plasma-kio.log',
                 'plasma-before.json', 'plasma-after.json', 'plasma-process-maps.log', 'plasma-result.json',
                 'x11-client.log', 'x11.rgba', 'xwayland-result.json', 'xwayland-process-maps.log',
                 'private-xwayland.json',
                 'desktop-session-result.json', 'desktop-result.json'):
        src = stage / name
        if not src.exists():
            continue
        s = src.lstat()
        m.check(stat.S_ISREG(s.st_mode) and s.st_uid == 0, 'Unexpected log type or owner: ' + name)
        limit = 32 * 1024 * 1024
        with src.open('rb') as f:
            if s.st_size > limit:
                f.seek(-limit, os.SEEK_END)
            (out / name).write_bytes(f.read(limit))
        copied.append({'name': name, 'source_bytes': s.st_size, 'tail_only': s.st_size > limit})
    recovery = {'current_boot_id': current_boot, 'test_boot_id': previous.get('boot_id'),
                'reboot_observed': bool(previous.get('boot_id')) and previous['boot_id'] != current_boot,
                'hardware_watchdog_reset_proven': False, 'copied': copied}
    try:
        # Report exact changed filenames even if validation subsequently fails.
        baseline = json.loads((backup / 'efi-sha256.json').read_text())
        report = json.loads((backup / 'report.json').read_text())
        esp = Path(report['esp'])
        live = {str(p.relative_to(esp)):m.sha(p) for p in sorted(esp.rglob('*')) if p.is_file()}
        difference = m.compare_esp(baseline, live)
        recovery['esp_comparison'] = difference
        recovery['all_efi_files_identical'] = not any(difference[k] for k in ('added', 'removed', 'changed'))
        m.verify_backup(backup, post_reboot=recovery['reboot_observed'])
        recovery['original_boot_and_efi_verified'] = True
        recovery['verification_scope'] = 'All baseline checks; after observed reboot only loader/random-seed content rotation is allowed. Added/removed files or any other changed content fail.'
    except Exception as e:
        recovery.update(original_boot_and_efi_verified=False, verification_error=str(e))
    boot_id = previous.get('boot_id')
    if boot_id:
        with (out / 'service-journal.log').open('w') as log:
            r = subprocess.run(['journalctl', '--boot=' + uuid.UUID(boot_id).hex, '--no-pager', '-n', '2000',
                                '-u', 'mtt-s30-once.service', '-u', 'mtt-s30-deadline.service'],
                               stdout=log, stderr=subprocess.STDOUT, timeout=30, env=m.ENV)
        recovery['journal_exit'] = r.returncode
    recovery['client_core'] = export_client_core(stage, boot_id, out)
    recovery['qt_client_core'] = export_client_core(stage, boot_id, out, 'qt-check')
    recovery['x11_client_core'] = export_client_core(stage, boot_id, out, 'x11-check')
    recovery['plasma_core'] = export_client_core(stage, boot_id, out, 'plasmashell')
    recovery['xwayland_core'] = export_client_core(stage, boot_id, out, 'Xwayland')
    (out / 'recovery-result.json').write_text(json.dumps(recovery, ensure_ascii=False, indent=2) + '\n')
    for p in out.iterdir():
        p.chmod(0o600)
        os.chown(p, uid, gid)
    os.chown(out, uid, gid)
    print('Logs copied to:', out)
    print('Recovery verification:', recovery['original_boot_and_efi_verified'])


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print('STOP: ' + str(e), file=sys.stderr)
        sys.exit(1)
