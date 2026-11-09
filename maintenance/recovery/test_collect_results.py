import importlib.util
import json
import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

spec = importlib.util.spec_from_file_location('collector', Path(__file__).with_name('collect-results.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

BOOT = '498cde3c-d518-42d2-a5d3-c34131d38a28'
HEX_BOOT = BOOT.replace('-', '')
STAGE = Path('/var/lib/mtt-s30-test/20261103-104000/test')
REAL_FSTAT = os.fstat


def root_stat(fd):
    s = REAL_FSTAT(fd)
    return SimpleNamespace(st_uid=0, st_mode=s.st_mode, st_size=s.st_size,
                           st_mtime_ns=s.st_mtime_ns, st_ctime_ns=s.st_ctime_ns)


class CoreExport(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.cores = self.root / 'cores'
        self.out = self.root / 'export'
        self.cores.mkdir(mode=0o700)
        self.out.mkdir(mode=0o700)
        self.source = self.cores / f'core.egl-check.0.{HEX_BOOT}.24001.1793673651000000.zst'
        self.source.write_bytes(b'bounded compressed core fixture')
        self.source.chmod(0o600)
        self.record = {'_BOOT_ID': HEX_BOOT, 'COREDUMP_EXE': str(STAGE / 'desktop/egl-check'),
                       'COREDUMP_UNIT': 'mtt-s30-once.service', 'COREDUMP_SIGNAL': '11',
                       'COREDUMP_UID': '0', 'COREDUMP_PID': '24001',
                       'COREDUMP_TIMESTAMP': '1793673651000000',
                       'COREDUMP_FILENAME': str(self.source)}
        self.enterContext(mock.patch.object(m, 'CORE_DIRECTORY', self.cores))
        self.enterContext(mock.patch.object(m.os, 'fstat', side_effect=root_stat))

    def test_matching_core_is_copied_unchanged(self):
        result = m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.assertEqual(result['status'], 'copied')
        exported = self.out / result['name']
        self.assertEqual(exported.read_bytes(), self.source.read_bytes())
        self.assertEqual(result['sha256'], m.m.sha(self.source))
        self.assertEqual(result['signal'], '11')

    def test_sigabrt_is_exported_with_the_same_identity_restrictions(self):
        aborted = dict(self.record, COREDUMP_SIGNAL='6')
        for key, wrong in (('_BOOT_ID', 'a' * 32), ('COREDUMP_EXE', '/usr/bin/other'),
                           ('COREDUMP_UNIT', 'other.service'), ('COREDUMP_UID', '1000')):
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                m.copy_client_core(dict(aborted, **{key: wrong}), STAGE, BOOT, self.out)
        with mock.patch.object(m.subprocess, 'run', return_value=SimpleNamespace(
                returncode=0, stdout=json.dumps(aborted) + '\n')):
            result = m.export_client_core(STAGE, BOOT, self.out)
        self.assertEqual(result['status'], 'copied')
        self.assertEqual(result['signal'], '6')
        self.assertEqual((self.out / result['name']).read_bytes(), self.source.read_bytes())

    def test_other_or_malformed_signals_are_rejected(self):
        for signal in ('4', '9', '15', '', None, 6, ['6', '11']):
            with self.subTest(signal=signal), self.assertRaises(RuntimeError):
                m.copy_client_core(dict(self.record, COREDUMP_SIGNAL=signal), STAGE, BOOT, self.out)
        self.assertEqual(list(self.out.iterdir()), [])

    def test_wrong_process_boot_service_and_filename_are_rejected(self):
        for key, wrong in (('_BOOT_ID', 'a' * 32), ('COREDUMP_EXE', '/usr/bin/other'),
                           ('COREDUMP_UNIT', 'other.service'), ('COREDUMP_SIGNAL', '9'),
                           ('COREDUMP_UID', '1000'), ('COREDUMP_PID', '../secret'),
                           ('COREDUMP_FILENAME', str(self.root / self.source.name)),
                           ('COREDUMP_FILENAME', str(self.source) + '.unexpected')):
            with self.subTest(key=key, wrong=wrong), self.assertRaises((RuntimeError, ValueError)):
                m.copy_client_core(dict(self.record, **{key: wrong}), STAGE, BOOT, self.out)
        self.assertEqual(list(self.out.iterdir()), [])

    def test_symlinks_permissions_and_oversized_core_are_rejected(self):
        target = self.root / 'outside'
        self.source.rename(target)
        self.source.symlink_to(target)
        with self.assertRaises(OSError):
            m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.source.unlink()
        target.rename(self.source)
        self.source.chmod(0o622)
        with self.assertRaises(RuntimeError):
            m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.source.chmod(0o600)
        with mock.patch.object(m, 'CORE_LIMIT', 1), self.assertRaises(RuntimeError):
            m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.cores.chmod(0o777)
        with self.assertRaises(RuntimeError):
            m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.assertEqual(list(self.out.iterdir()), [])

    def test_deadline_removes_partial_export_and_preserves_existing_file(self):
        with mock.patch.object(m.time, 'monotonic', side_effect=[0, 11]), self.assertRaises(RuntimeError):
            m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.assertEqual(list(self.out.iterdir()), [])
        destination = self.out / 'egl-check.core.zst'
        destination.write_bytes(b'existing')
        with self.assertRaises(FileExistsError):
            m.copy_client_core(self.record, STAGE, BOOT, self.out)
        self.assertEqual(destination.read_bytes(), b'existing')

    def test_optional_query_is_exact_and_failures_do_not_raise(self):
        response = SimpleNamespace(returncode=0, stdout=json.dumps(self.record) + '\n')
        with mock.patch.object(m.subprocess, 'run', return_value=response) as run:
            result = m.export_client_core(STAGE, BOOT, self.out)
        self.assertEqual(result['status'], 'copied')
        command = run.call_args.args[0]
        for required in ('--boot=' + HEX_BOOT, 'COREDUMP_EXE=' + str(STAGE / 'desktop/egl-check'),
                         'COREDUMP_UNIT=mtt-s30-once.service', 'COREDUMP_UID=0'):
            self.assertIn(required, command)
        self.assertEqual({arg for arg in command if arg.startswith('COREDUMP_SIGNAL=')},
                         {'COREDUMP_SIGNAL=6', 'COREDUMP_SIGNAL=11'})
        # A top-level '+' would OR entire restriction groups and could include
        # another boot, executable or service; same-field matches need none.
        self.assertNotIn('+', command)
        for output, status in (('', 'not_found'), ('{}\n{}\n', 'unavailable'), ('bad json', 'unavailable')):
            with mock.patch.object(m.subprocess, 'run', return_value=SimpleNamespace(returncode=0, stdout=output)):
                self.assertEqual(m.export_client_core(STAGE, BOOT, self.out)['status'], status)
        with mock.patch.object(m.subprocess, 'run', side_effect=TimeoutError('test timeout')):
            self.assertEqual(m.export_client_core(STAGE, BOOT, self.out)['status'], 'unavailable')

    def qt_record(self):
        source = self.cores / self.source.name.replace('core.egl-check.', 'core.qt-check.')
        source.write_bytes(b'Qt client compressed core fixture')
        source.chmod(0o600)
        return dict(self.record, COREDUMP_EXE=str(STAGE / 'desktop/qt-check'),
                    COREDUMP_FILENAME=str(source), COREDUMP_SIGNAL='6')

    def test_qt_and_egl_cores_are_independent(self):
        egl = m.copy_client_core(self.record, STAGE, BOOT, self.out)
        qt_record = self.qt_record()
        qt = m.copy_client_core(qt_record, STAGE, BOOT, self.out, 'qt-check')
        self.assertEqual(egl['name'], 'egl-check.core.zst')
        self.assertEqual(qt['name'], 'qt-check.core.zst')
        self.assertEqual((self.out / egl['name']).read_bytes(), self.source.read_bytes())
        self.assertEqual((self.out / qt['name']).read_bytes(), Path(qt_record['COREDUMP_FILENAME']).read_bytes())
        self.assertEqual(qt['sha256'], m.m.sha(self.out / qt['name']))
        self.assertIn('qt-check process', qt['scope'])

    def test_qt_core_keeps_all_identity_and_filename_restrictions(self):
        qt = self.qt_record()
        for key, wrong in (('_BOOT_ID', 'b' * 32), ('COREDUMP_EXE', str(STAGE / 'desktop/egl-check')),
                           ('COREDUMP_EXE', '/usr/bin/qt-check'), ('COREDUMP_UNIT', 'other.service'),
                           ('COREDUMP_UID', '1000'), ('COREDUMP_SIGNAL', '9'),
                           ('COREDUMP_PID', '../outside'), ('COREDUMP_FILENAME', str(self.source)),
                           ('COREDUMP_FILENAME', str(self.root / Path(qt['COREDUMP_FILENAME']).name))):
            with self.subTest(key=key, wrong=wrong), self.assertRaises((RuntimeError, ValueError)):
                m.copy_client_core(dict(qt, **{key: wrong}), STAGE, BOOT, self.out, 'qt-check')
        self.assertEqual(list(self.out.iterdir()), [])

    def test_qt_journal_query_cannot_match_another_client(self):
        response = SimpleNamespace(returncode=0, stdout=json.dumps(self.qt_record()) + '\n')
        with mock.patch.object(m.subprocess, 'run', return_value=response) as run:
            result = m.export_client_core(STAGE, BOOT, self.out, 'qt-check')
        self.assertEqual(result['status'], 'copied')
        command = run.call_args.args[0]
        self.assertIn('COREDUMP_EXE=' + str(STAGE / 'desktop/qt-check'), command)
        self.assertNotIn('COREDUMP_EXE=' + str(STAGE / 'desktop/egl-check'), command)
        for exact in ('--boot=' + HEX_BOOT, 'COREDUMP_UNIT=mtt-s30-once.service', 'COREDUMP_UID=0'):
            self.assertIn(exact, command)
        self.assertNotIn('+', command)
        self.assertEqual({arg for arg in command if arg.startswith('COREDUMP_SIGNAL=')},
                         {'COREDUMP_SIGNAL=6', 'COREDUMP_SIGNAL=11'})
        with mock.patch.object(m.subprocess, 'run') as run:
            for invalid in ('other-client', '../qt-check', '/usr/bin/qt-check'):
                self.assertEqual(m.export_client_core(STAGE, BOOT, self.out, invalid)['status'], 'unavailable')
            run.assert_not_called()

    def system_record(self, client):
        source = self.cores / self.source.name.replace('core.egl-check.', 'core.' + client + '.')
        source.write_bytes((client + ' compressed core fixture').encode())
        source.chmod(0o600)
        return dict(self.record, COREDUMP_EXE=m.SYSTEM_CORE_CLIENTS[client][0],
                    COREDUMP_FILENAME=str(source), COREDUMP_SIGNAL='6')

    def test_x11_staged_client_uses_its_exact_executable_and_name(self):
        source = self.cores / self.source.name.replace('egl-check', 'x11-check')
        source.write_bytes(b'X11 core'); source.chmod(0o600)
        record = dict(self.record, COREDUMP_EXE=str(STAGE / 'desktop/x11-check'), COREDUMP_FILENAME=str(source))
        with mock.patch.object(m.subprocess, 'run', return_value=SimpleNamespace(returncode=0, stdout=json.dumps(record))) as run:
            result = m.export_client_core(STAGE, BOOT, self.out, 'x11-check')
        self.assertEqual(result['name'], 'x11-check.core.zst')
        self.assertIn('COREDUMP_EXE=' + str(STAGE / 'desktop/x11-check'), run.call_args.args[0])
        self.assertNotIn('+', run.call_args.args[0])

    def test_system_core_requires_exact_recorded_pid_as_well_as_executable(self):
        for client in m.SYSTEM_CORE_CLIENTS:
            record = self.system_record(client)
            with self.subTest(client=client), self.assertRaises(RuntimeError):
                m.copy_client_core(record, STAGE, BOOT, self.out, client)
            for key, wrong in (('COREDUMP_PID', '24002'), ('COREDUMP_EXE', '/usr/bin/other'),
                               ('COREDUMP_UID', '1000'), ('COREDUMP_UNIT', 'other.service'),
                               ('_BOOT_ID', 'f' * 32), ('COREDUMP_SIGNAL', '15'),
                               ('COREDUMP_FILENAME', str(self.source))):
                with self.subTest(client=client, key=key), self.assertRaises(RuntimeError):
                    m.copy_client_core(record | {key: wrong}, STAGE, BOOT, self.out, client, '24001')
            result = m.copy_client_core(record, STAGE, BOOT, self.out, client, '24001')
            self.assertEqual(result['name'], client + '.core.zst')

    def test_system_query_cannot_expand_beyond_the_recorded_root_process(self):
        stage = self.root / 'stage'; stage.mkdir()
        for client, (executable, filename, keys) in m.SYSTEM_CORE_CLIENTS.items():
            record = self.system_record(client)
            value = {'shell_pid': 24001} if client == 'plasmashell' else {'server': {'pid': 24001}}
            (stage / filename).write_text(json.dumps(value))
            with mock.patch.object(m.subprocess, 'run', return_value=SimpleNamespace(returncode=0, stdout=json.dumps(record))) as run:
                result = m.export_client_core(stage, BOOT, self.out, client)
            self.assertEqual(result['status'], 'copied')
            args = run.call_args.args[0]
            for exact in ('COREDUMP_PID=24001', 'COREDUMP_EXE=' + executable,
                          '--boot=' + HEX_BOOT, 'COREDUMP_UNIT=mtt-s30-once.service', 'COREDUMP_UID=0'):
                self.assertIn(exact, args)
            self.assertNotIn('+', args)
            self.assertEqual({arg for arg in args if arg.startswith('COREDUMP_SIGNAL=')},
                             {'COREDUMP_SIGNAL=6', 'COREDUMP_SIGNAL=11'})
            with mock.patch.object(m.subprocess, 'run', side_effect=TimeoutError('timeout')):
                self.assertEqual(m.export_client_core(stage, BOOT, self.out, client)['status'], 'unavailable')

    def test_old_or_incomplete_results_skip_system_core_queries(self):
        stage = self.root / 'stage'; stage.mkdir()
        with mock.patch.object(m.subprocess, 'run') as run:
            for client, (executable, filename, keys) in m.SYSTEM_CORE_CLIENTS.items():
                self.assertEqual(m.export_client_core(stage, BOOT, self.out, client)['status'], 'skipped')
                (stage / filename).write_text('{}')
                self.assertEqual(m.export_client_core(stage, BOOT, self.out, client)['status'], 'skipped')
            run.assert_not_called()

    def test_untrusted_system_pid_records_never_enable_a_query(self):
        stage = self.root / 'stage'; stage.mkdir()
        path = stage / 'plasma-result.json'
        with mock.patch.object(m.subprocess, 'run') as run:
            for pid in (True, 0, -1, 2 ** 31, '24001', [], None):
                path.write_text(json.dumps({'shell_pid': pid}))
                with self.subTest(pid=pid):
                    self.assertEqual(m.export_client_core(stage, BOOT, self.out, 'plasmashell')['status'], 'unavailable')
            path.write_text(json.dumps({'shell_pid': 24001}));path.chmod(0o666)
            self.assertEqual(m.export_client_core(stage, BOOT, self.out, 'plasmashell')['status'], 'unavailable')
            path.chmod(0o600);path.rename(stage / 'target');path.symlink_to(stage / 'target')
            self.assertEqual(m.export_client_core(stage, BOOT, self.out, 'plasmashell')['status'], 'unavailable')
            run.assert_not_called()


class QtLogs(unittest.TestCase):
    def test_main_exports_qt_payloads_and_separate_core_metadata(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            backups, exports = root / 'backups', root / 'exports'
            backup = backups / '20261109-153310'
            stage = backup / 'test'
            stage.mkdir(parents=True, mode=0o700)
            exports.mkdir()
            esp = root / 'efi'
            esp.mkdir()
            (esp / 'kernel').write_bytes(b'kernel fixture')
            (backup / 'efi-sha256.json').write_text(json.dumps({'kernel': m.m.sha(esp / 'kernel')}))
            (backup / 'report.json').write_text(json.dumps({'esp': str(esp)}))
            (stage / 'supervisor-result.json').write_text(json.dumps({'boot_id': BOOT}))
            payloads = {'qt-client.log': b'Qt test output', 'qt.rgba': b'rgba bytes',
                        'qt.rgba.png': b'png bytes', 'wayland-client.log': b'legacy EGL output',
                        'plasma.log': b'plasma', 'plasma-activities.log': b'activities', 'plasma-kio.log': b'kio',
                        'plasma-before.json': b'{}', 'plasma-after.json': b'{}',
                        'plasma-process-maps.log': b'maps', 'plasma-result.json': b'{"shell_pid": 24001}',
                        'x11-client.log': b'X11 output', 'x11.rgba': b'X11 pixels',
                        'xwayland-result.json': b'{"server": {"pid": 24002}}', 'xwayland-process-maps.log': b'Xwayland maps',
                        'private-xwayland.json': json.dumps({'display': ':100',
                            'xauthority': str(stage / 'desktop-runtime/xauthority')}).encode()}
            for name, data in payloads.items():
                (stage / name).write_bytes(data)
            (stage / 'xauthority').write_bytes(b'must not export authentication cookie')
            (stage / 'session-bus.conf').write_bytes(b'must not export DBus configuration')
            current = root / 'boot-id'
            current.write_text('812ae8c5-0a59-4809-96da-3b96172be7dc')
            real_stat = Path.stat

            def mapped_path(value):
                replacements = {'/var/lib/mtt-s30-test': backups, '/var/tmp': exports,
                                '/proc/sys/kernel/random/boot_id': current}
                return replacements.get(str(value), Path(value))

            def as_root(path, *args, **kwargs):
                result = real_stat(path, *args, **kwargs)
                values = list(result)
                values[4] = 0
                return os.stat_result(values)

            def core_result(stage, boot_id, out, client='egl-check'):
                return {'status': 'not_found', 'client': client}

            with mock.patch.object(m, 'Path', side_effect=mapped_path), \
                 mock.patch.object(Path, 'stat', autospec=True, side_effect=as_root), \
                 mock.patch.object(Path, 'lstat', autospec=True,
                                   side_effect=lambda path: as_root(path, follow_symlinks=False)), \
                 mock.patch.object(m.os, 'geteuid', return_value=0), \
                 mock.patch.object(m.os, 'chown'), \
                 mock.patch.dict(m.os.environ, {'SUDO_UID': '1000', 'SUDO_GID': '1000'}), \
                 mock.patch.object(m.sys, 'argv', ['collect-results.py', str(backup)]), \
                 mock.patch.object(m.m, 'verify_backup'), \
                 mock.patch.object(m.subprocess, 'run', return_value=SimpleNamespace(returncode=0)), \
                 mock.patch.object(m, 'export_client_core', side_effect=core_result):
                m.main()
            out = exports / ('mtt-s30-results-' + backup.name)
            for name, data in payloads.items():
                self.assertEqual((out / name).read_bytes(), data)
            recovery = json.loads((out / 'recovery-result.json').read_text())
            self.assertTrue(recovery['original_boot_and_efi_verified'])
            self.assertEqual(recovery['client_core']['client'], 'egl-check')
            self.assertEqual(recovery['qt_client_core']['client'], 'qt-check')
            self.assertEqual(recovery['x11_client_core']['client'], 'x11-check')
            self.assertEqual(recovery['plasma_core']['client'], 'plasmashell')
            self.assertEqual(recovery['xwayland_core']['client'], 'Xwayland')
            self.assertFalse((out / 'xauthority').exists())
            self.assertFalse((out / 'session-bus.conf').exists())
            self.assertTrue(set(payloads) <= {row['name'] for row in recovery['copied']})


if __name__ == '__main__':
    unittest.main()
