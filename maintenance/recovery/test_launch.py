"""Fresh-preflight chaining tests. No privileged operation is executed."""
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import Mock

spec=importlib.util.spec_from_file_location('launch',Path(__file__).with_name('prepare-and-test.py'))
m=importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class Launch(unittest.TestCase):
    def test_preflight_failure_never_starts_test(self):
        prepare=Mock();runner=Mock()
        prepare.main.side_effect=RuntimeError('backup verification failed')
        with self.assertRaises(RuntimeError):
            m.launch(prepare,runner)
        runner.start.assert_not_called()

    def test_uses_exact_fresh_backup(self):
        prepare=Mock();runner=Mock()
        backup=Path('/var/lib/mtt-s30-test/new-test-only')
        prepare.main.return_value=backup
        self.assertEqual(m.launch(prepare,runner),backup)
        runner.start.assert_called_once_with(backup)

    def test_missing_path_never_reuses_old_backup(self):
        prepare=Mock();runner=Mock();prepare.main.return_value=None
        with self.assertRaises(RuntimeError):
            m.launch(prepare,runner)
        runner.start.assert_not_called()

    def test_workload_mode_uses_fresh_backup_and_explicit_profile(self):
        prepare=Mock();runner=Mock();backup=Path('/var/lib/mtt-s30-test/workloads')
        prepare.main.return_value=backup
        self.assertEqual(m.launch(prepare,runner,workloads=True),backup)
        runner.start.assert_called_once_with(backup,workloads=True)

    def test_desktop_mode_is_explicit_and_uses_fresh_backup(self):
        prepare=Mock();runner=Mock();backup=Path('/var/lib/mtt-s30-test/desktop')
        prepare.main.return_value=backup
        self.assertEqual(m.launch(prepare,runner,desktop=True),backup)
        runner.start.assert_called_once_with(backup,desktop=True)

    def test_desktop_version_drift_stops_before_backup(self):
        prepare=Mock();runner=Mock()
        runner.desktop_support.verify_host.side_effect=RuntimeError('desktop packages changed')
        with self.assertRaisesRegex(RuntimeError,'desktop packages changed'):
            m.launch(prepare,runner,desktop=True)
        prepare.main.assert_not_called()
        runner.start.assert_not_called()


if __name__=='__main__':
    unittest.main()
