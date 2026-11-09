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

    def test_wrong_process_boot_service_and_filename_are_rejected(self):
        for key, wrong in (('_BOOT_ID', 'a' * 32), ('COREDUMP_EXE', '/usr/bin/other'),
                           ('COREDUMP_UNIT', 'other.service'), ('COREDUMP_SIGNAL', '6'),
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
                         'COREDUMP_UNIT=mtt-s30-once.service', 'COREDUMP_SIGNAL=11', 'COREDUMP_UID=0'):
            self.assertIn(required, command)
        for output, status in (('', 'not_found'), ('{}\n{}\n', 'unavailable'), ('bad json', 'unavailable')):
            with mock.patch.object(m.subprocess, 'run', return_value=SimpleNamespace(returncode=0, stdout=output)):
                self.assertEqual(m.export_client_core(STAGE, BOOT, self.out)['status'], status)
        with mock.patch.object(m.subprocess, 'run', side_effect=TimeoutError('test timeout')):
            self.assertEqual(m.export_client_core(STAGE, BOOT, self.out)['status'], 'unavailable')


if __name__ == '__main__':
    unittest.main()
