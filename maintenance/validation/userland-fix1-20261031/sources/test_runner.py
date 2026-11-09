"""Host-safe regression tests: mock privileged operations, never open a watchdog."""
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('runner', Path(__file__).with_name('test-once.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class RecoveryRunner(unittest.TestCase):
    def test_private_dependency_failure_never_starts_transient_service(self):
        with tempfile.TemporaryDirectory() as tmp:
            backup=Path(tmp)
            with patch.object(m,'audit'),patch.object(m,'verify_backup',return_value={}), \
                 patch.object(m.desktop_support,'verify_host'), \
                 patch.object(m.shutil,'which',return_value='/usr/bin/tool'), \
                 patch.object(m.subprocess,'run') as run, \
                 patch.object(m.desktop_support,'verify_runtime_dependencies',
                              side_effect=RuntimeError('missing private dependency')):
                with self.assertRaisesRegex(RuntimeError,'missing private dependency'):
                    m.start(backup,desktop=True)
            self.assertEqual([call.args[0][0] for call in run.call_args_list],['bsdtar','bsdtar'])
            self.assertFalse((backup/'test/config.json').exists())

    def test_historical_module_is_audit_only_and_unknown_module_is_rejected(self):
        old='39290bf0fee97d8dfbce41959b9869efb5b10dc0f7dd3c495568b92b1d721558'
        for post in (False,True):
            self.assertEqual(m.expected_module_sha({'module_sha256':m.MODULE_SHA},post),m.MODULE_SHA)
            for unknown in ({},{'module_sha256':'0'*64}):
                with self.assertRaises(RuntimeError):m.expected_module_sha(unknown,post)
        for old in m.REVIEWED_MODULES - {m.MODULE_SHA}:
            self.assertEqual(m.expected_module_sha({'module_sha256':old},True),old)
            with self.assertRaises(RuntimeError):m.expected_module_sha({'module_sha256':old})

    def test_public_summary_survives_service_umask_and_replacement(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / 'summary.json'
            old = os.umask(0o077)
            try:
                m.save(path, {'phase': 'staged'})
                m.save(path, {'phase': 'failed'})
            finally:
                os.umask(old)
            self.assertEqual(stat.S_IMODE(path.stat().st_mode), 0o644)
            self.assertEqual(json.loads(path.read_text()), {'phase': 'failed'})
            self.assertEqual(list(Path(d).iterdir()), [path])

    def test_summary_replaces_symlink_without_following(self):
        with tempfile.TemporaryDirectory() as d:
            victim = Path(d) / 'victim'
            victim.write_text('keep')
            path = Path(d) / 'summary.json'
            path.symlink_to(victim)
            m.save(path, {'phase': 'staged'})
            self.assertEqual(victim.read_text(), 'keep')
            self.assertFalse(path.is_symlink())

    def test_boot_default_must_equal_running_entry(self):
        good = {'id': 'working.conf', 'type': 'type1', 'isSelected': True, 'isDefault': True}
        m.check_boot_entries([good], 'working.conf')
        with self.assertRaises(RuntimeError):
            m.check_boot_entries([{**good, 'isDefault': False},
                                  {'id': 'untested.conf', 'isDefault': True}], 'working.conf')
        with self.assertRaises(RuntimeError):
            m.check_boot_entries([], 'working.conf')

    def test_seed_rotation_is_only_accepted_after_reboot(self):
        baseline={'loader/random-seed':'old', 'kernel':'K', 'initrd':'I', 'loader/entries/working.conf':'E'}
        live={**baseline,'loader/random-seed':'new'}
        diff=m.compare_esp(baseline,live)
        self.assertEqual(diff['changed'],['loader/random-seed'])
        self.assertEqual(diff['unchanged_files'],3)
        with self.assertRaises(RuntimeError):
            m.check_esp_difference(diff)
        m.check_esp_difference(diff,post_reboot=True)

    def test_boot_image_or_seed_file_set_changes_still_fail(self):
        baseline={'loader/random-seed':'old','kernel':'K'}
        for live in ({**baseline,'kernel':'changed'}, {'kernel':'K'},
                     {**baseline,'new-entry':'unexpected'}):
            with self.subTest(live=live), self.assertRaises(RuntimeError):
                m.check_esp_difference(m.compare_esp(baseline,live),post_reboot=True)

    def test_vulkan_rejects_software_and_wrong_device(self):
        m.validate_vulkan('vendorID = 0x1ed5\ndeviceID = 0x0102\ndeviceName = MTT S30')
        for text in ('vendorID = 0x1002\ndeviceID = 0x0102',
                     'vendorID = 0x1ed5\ndeviceID = 0x0300',
                     'vendorID = 0x1ed5\ndeviceID = 0x0102\nllvmpipe'):
            with self.assertRaises(RuntimeError):
                m.validate_vulkan(text)

    def test_kernel_faults_stop_progress(self):
        self.assertFalse(m.kernel_faults('[12] mtgpu: initialized'))
        self.assertFalse(m.kernel_faults('systemd: unrelated.service timed out'))
        for line in ('BUG: unable to handle page fault', 'WARNING: Unpatched return thunk in use',
                     'AMD-Vi: IO_PAGE_FAULT', 'mtgpu: GPU reset', 'firmware: load failed',
                     'resource: resource sanity check: requesting [mem x-y]',
                     'caller vpu_component_bind [mtgpu] mapping multiple BARs',
                     'DISPC-2: dispc_stop() wait dispc disable done timed out',
                     'S30 firmware display stop failed: -110',
                     'VPU register layout rejected: -22',
                     'Failed to bind other components (ret=-19)'):
            self.assertEqual(m.kernel_faults(line), [line])

    def test_countdown_and_ping_are_verified_and_original_timeout_restored(self):
        with tempfile.TemporaryDirectory() as d, patch.object(m, 'WATCH', Path(d)), \
             patch.object(m, 'arm', return_value=(42, 60, 'SP5100 TCO timer')), \
             patch.object(m, 'disarm') as disarm, patch.object(m.time, 'sleep'), \
             patch.object(m, 'integer_ioctl', side_effect=[60, 57, 0, 60, 90]) as ioctl:
            (Path(d) / 'timeout').write_text('90')
            result = m.calibrate_watchdog()
            self.assertEqual(result['after_3s'], 57)
            self.assertFalse(result['hardware_reset_verified'])
            self.assertEqual(ioctl.call_args_list[-1].args, (42, m.SETTIMEOUT, 90))
            disarm.assert_called_once_with(42)

    def test_stuck_countdown_disarms_without_starting_gpu(self):
        with tempfile.TemporaryDirectory() as d, patch.object(m, 'WATCH', Path(d)), \
             patch.object(m, 'arm', return_value=(42, 60, 'SP5100 TCO timer')), \
             patch.object(m, 'disarm') as disarm, patch.object(m.time, 'sleep'), \
             patch.object(m, 'integer_ioctl', side_effect=[60, 60, 60]):
            (Path(d) / 'timeout').write_text('60')
            with self.assertRaisesRegex(RuntimeError, 'not decreasing'):
                m.calibrate_watchdog()
            disarm.assert_called_once_with(42)

    def test_running_x11_or_unknown_process_check_refuses_load(self):
        with patch.object(m, 'desktop_snapshot', return_value={'settled':False,'graphical_processes':['42 Xorg']}):
            with self.assertRaises(RuntimeError):
                m.ensure_desktop_stopped(timeout=0)

    def test_delayed_kwin_shutdown_is_waited_for_with_evidence(self):
        clock=[0.0];observed=[]
        def sleep(seconds):clock[0]+=seconds
        samples=[{'settled':False,'graphical_processes':['42 kwin_wayland']},
                 {'settled':False,'graphical_processes':['42 kwin_wayland']},
                 {'settled':True,'graphical_processes':[]},
                 {'settled':True,'graphical_processes':[]}]
        with patch.object(m,'desktop_snapshot',side_effect=samples), \
             patch.object(m.time,'monotonic',side_effect=lambda:clock[0]), \
             patch.object(m.time,'sleep',side_effect=sleep):
            m.ensure_desktop_stopped(timeout=20,report=observed.append)
        self.assertEqual(len(observed),4)
        self.assertEqual(observed[-1]['elapsed_seconds'],3)

    def test_temporarily_clear_desktop_does_not_bypass_drm_gate(self):
        clock=[0.0];observed=[]
        def sleep(seconds):clock[0]+=seconds
        samples=[{'settled':True}, {'settled':False,'drm_users':'123'}, {'settled':True}]
        with patch.object(m,'desktop_snapshot',side_effect=samples), \
             patch.object(m.time,'monotonic',side_effect=lambda:clock[0]), \
             patch.object(m.time,'sleep',side_effect=sleep), self.assertRaises(RuntimeError):
            m.ensure_desktop_stopped(timeout=2,report=observed.append)
        self.assertEqual(len(observed),3)

    def test_process_inspection_error_is_not_treated_as_idle(self):
        observed=[]
        with patch.object(m,'output',return_value='inactive'), \
             patch.object(m.subprocess,'run',return_value=subprocess.CompletedProcess([],2,'','syntax error')), \
             self.assertRaisesRegex(RuntimeError,'pgrep failed'):
            m.ensure_desktop_stopped(report=observed.append)
        self.assertIn('inspection_error',observed[0])

    def test_failed_probe_returns_nonzero_and_never_loads_driver(self):
        with tempfile.TemporaryDirectory() as d:
            backup = Path(d); stage = backup / 'test'; stage.mkdir()
            watch = backup / 'watch'; watch.mkdir(); (watch / 'state').write_text('active')
            firmware = backup / 'firmware'; firmware.write_text('')
            m.save(stage / 'config.json', {'firmware_before': ''})
            m.save(stage / 'supervisor-result.json', {'supervisor_pid': os.getppid(), 'phase': 'testing'})
            original_path = m.pathlib.Path
            def paths(value, *parts):
                if value == '/sys/module/firmware_class/parameters/path':
                    return firmware
                return original_path(value, *parts)
            with patch.object(m, 'WATCH', watch), patch.object(m.pathlib, 'Path', side_effect=paths), \
                 patch.object(m.os, 'sync'), \
                 patch.object(m.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1)) as run:
                self.assertEqual(m.probe(backup), 1)
            result = json.loads((stage / 'probe-result.json').read_text())
            self.assertEqual(result['phase'], 'failed')
            self.assertFalse(result['passed'])
            self.assertFalse(any('insmod' in c.args[0] for c in run.call_args_list))

    def test_probe_late_failures_never_become_success(self):
        # Exercise the complete probe after simulated PCI binding, without
        # touching the real display, mount, watchdog, firmware or GPU.
        for failure in ('vulkaninfo', 'vainfo', 'software-vulkan', 'resource-conflict', 'workload-fail', 'workload-pass', 'desktop-fail', 'desktop-pass', 'desktop-artifact', None):
            with self.subTest(failure=failure), tempfile.TemporaryDirectory() as d:
                backup = Path(d); stage = backup / 'test'; stage.mkdir()
                watch = backup / 'watch'; watch.mkdir(); (watch / 'state').write_text('active')
                gpu = backup / 'gpu'; gpu.mkdir(); (gpu / 'driver').symlink_to(backup / 'mtgpu')
                (gpu / 'drm' / 'renderD128').mkdir(parents=True)
                (gpu / 'drm' / 'card0').mkdir()
                firmware = backup / 'firmware'; firmware.write_text('')
                profile=m.workload_support.PROFILE if failure in ('workload-fail','workload-pass') else 'initialization'
                if failure in ('desktop-fail','desktop-pass','desktop-artifact'):profile=m.desktop_support.PROFILE
                m.save(stage / 'config.json', {'firmware_before': '', 'profile':profile})
                m.save(stage / 'supervisor-result.json', {'supervisor_pid': os.getppid(), 'phase': 'testing'})
                original_path = m.pathlib.Path
                def paths(value, *parts):
                    if value == '/sys/module/firmware_class/parameters/path':
                        return firmware
                    return original_path(value, *parts)
                def run(args, **kwargs):
                    log = kwargs['stdout']
                    if args[0] == 'dmesg':
                        log.write('[1] baseline\n')
                        if failure == 'resource-conflict' and log.name.endswith('kernel-check.log'):
                            log.write('[2] resource: resource sanity check: requesting [mem x-y]\n')
                    if args[0] == 'vulkaninfo':
                        log.write('vendorID = 0x1ed5\ndeviceID = 0x0102\n')
                        if failure == 'software-vulkan':
                            log.write('llvmpipe\n')
                    return subprocess.CompletedProcess(args, 1 if args[0] == failure else 0)
                with patch.object(m, 'WATCH', watch), patch.object(m, 'GPU', gpu), \
                     patch.object(m.pathlib, 'Path', side_effect=paths), patch.object(m.os, 'sync'), \
                     patch.object(m, 'ensure_desktop_stopped'), \
                     patch.object(m.subprocess, 'check_output', return_value='ro\n'), \
                     patch.object(m.subprocess, 'run', side_effect=run), \
                     patch.object(m.workload_support,'verify_bundle'), \
                     patch.object(m.workload_support,'run_workloads',return_value={'passed':True},
                                  side_effect=RuntimeError('workload failed') if failure=='workload-fail' else None), \
                     patch.object(m.desktop_support,'verify_host'), \
                     patch.object(m.desktop_support,'verify_bundle',side_effect=RuntimeError('bad desktop artifact') if failure=='desktop-artifact' else None), \
                     patch.object(m.desktop_support,'run_desktop',return_value={'passed':True},
                                  side_effect=RuntimeError('desktop failed') if failure=='desktop-fail' else None) as desktop:
                    code = m.probe(backup)
                    if failure=='desktop-artifact':desktop.assert_not_called()
                result = json.loads((stage / 'probe-result.json').read_text())
                success=failure in (None,'workload-pass','desktop-pass')
                self.assertEqual(code, 0 if success else 1)
                self.assertEqual(result['passed'], success)
                if failure=='workload-pass':
                    self.assertEqual(result['phase'],'workload_checks_passed')
                if failure=='desktop-pass':self.assertEqual(result['phase'],'desktop_checks_passed')
                if failure=='desktop-artifact':
                    self.assertFalse(result['module_load_attempted'])
                    self.assertNotIn('stop-desktop',result['checks'])
                if failure in ('vulkaninfo', 'software-vulkan'):
                    self.assertNotIn('vaapi', result['checks'])
                if failure == 'resource-conflict':
                    self.assertNotIn('mthreads-gmi', result['checks'])
                    self.assertNotIn('vulkan', result['checks'])
                    self.assertNotIn('vaapi', result['checks'])


if __name__ == '__main__':
    unittest.main()
