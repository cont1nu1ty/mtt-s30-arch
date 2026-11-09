#!/usr/bin/env python3
"""Read-only checks of the prepared private candidate; no GPU initialization."""
from pathlib import Path
import datetime, hashlib, json, re, subprocess, sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'maintenance/recovery'))
import desktop_support as d
from workload_support import last_json
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
bundle = ROOT / 'builds' / d.BUNDLE_DIRECTORY
work = ROOT / 'work/kwin-import-table-final-20261104'
archive = ROOT / 'maintenance/validation/userland-fix7-20261104'
software = ROOT / 'work/userland-fix7-software-20261104'
base = ROOT / 'builds/desktop-userland-fix6-20261104'
d.verify_host(); d.verify_bundle(bundle); d.verify_bundle(software / 'desktop')
manifest = json.loads((bundle / 'manifest.json').read_text())
base_manifest = json.loads((base / 'manifest.json').read_text())
for name, metadata in manifest['files'].items():
 if not name.startswith('kwin/'):
  assert metadata == base_manifest['files'][name], name
  assert sha(bundle / name) == sha(base / name), name
assert sha(archive / 'build-kwin-compat.py') == manifest['builder_sha256']
for name, expected in manifest['patches'].items():
 assert sha(ROOT / 'patches' / name) == expected, name
for subject in ('source', 'library'):
 result = json.loads((ROOT / ('work/v8-format-tests-20261104/final-' + subject) / 'results.json').read_text())
 assert result['passed'] and result['case_count'] == 35 and result['subject'] == subject
 assert result['library_sha256'] == manifest['files']['kwin/libkwin.so.6']['sha256']
 assert all(case['exit'] == 0 and case['log_marker_passed'] for case in result['cases'])
 assert result['baseline_counterexample']['rejected_by_new_case'] and result['baseline_counterexample']['exit'] == 42
test_log = (work / 'recovery-tests.log').read_text()
match = re.search(r'Ran (\d+) tests', test_log)
assert match and int(match[1]) >= 62 and test_log.rstrip().endswith('OK')
window = last_json(software / 'wayland-client.log')
d.validate_egl(window, software / 'wayland.rgba', window=True, software=True)
try:
 d.validate_egl(window, software / 'wayland.rgba', window=True, software=False)
except RuntimeError:
 rejected = True
else:
 raise AssertionError('Software result must not pass as S30')
session = json.loads((software / 'desktop-session-result.json').read_text())
assert session['passed'] and session['mode'] == 'virtual-software' and not session['forced_kill']
assert d.BUILD_MARKER in (software / 'kwin.log').read_text()
stage = work / 'dependency-stage'
stage.mkdir()
d.stage_bundle(bundle, stage / 'desktop')
(stage / 'vendor').symlink_to(ROOT / 'official/driver-3.1.0', target_is_directory=True)
d.verify_runtime_dependencies(stage)
module = ROOT / 'builds/runtime-fix3-v2-7.2.14-20261103/source/mtgpu.ko'
assert sha(module) == '6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff'
kernel = subprocess.check_output(['uname', '-r'], text=True).strip()
assert kernel == '7.2.14-arch1-1'
assert subprocess.check_output(['modinfo', '-F', 'vermagic', str(module)], text=True).startswith(kernel + ' ')
assert not Path('/sys/module/mtgpu').exists()
lookup = subprocess.run(['modinfo', '-n', 'mtgpu'], capture_output=True, text=True)
assert lookup.returncode == 1 and 'Module mtgpu not found' in lookup.stderr
services = {name: subprocess.run(['systemctl', 'is-active', name], capture_output=True, text=True).stdout.strip()
 for name in ('display-manager.service', 'mtt-s30-once.service', 'mtt-s30-deadline.timer')}
assert services == {'display-manager.service': 'active', 'mtt-s30-once.service': 'inactive', 'mtt-s30-deadline.timer': 'inactive'}
watchdog = Path('/sys/class/watchdog/watchdog0/state').read_text().strip()
assert watchdog == 'inactive'
prior = ROOT / 'maintenance/validation/runtime-20261104-200750'
for name, expected in json.loads((prior / 'evidence-sha256.json').read_text()).items():
 assert sha(prior / name) == expected
assert json.loads((prior / 'recovery-result.json').read_text())['original_boot_and_efi_verified']
result = dict(profile=d.PROFILE, manifest_sha256=sha(bundle/'manifest.json'), kernel=kernel,
 module_sha256=sha(module), egl_sha256=sha(bundle/'egl/libEGL_mesa.so.0'),
 kwin_library_sha256=sha(bundle/'kwin/libkwin.so.6'), patch_sha256=manifest['patches']['kwin-6.8.2-mtgpu-import-formats.patch'],
 reviewed_packages=d.REVIEWED_DESKTOP_PACKAGES, checked_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),
 recovery_tests_passed=int(match[1]), actual_source_format_cases=35, actual_library_format_cases=35,
 same_cases_executed_against_source_and_library=True, client_egl_unchanged=True,
 old_v7_rejected_by_real_trace_counterexample=True, vendor_import_table_verified_from_pinned_elf=True,
 inherited_egl_regression_evidence='validation/userland-fix5-20261104/validation.json',
 inherited_egl_regression_evidence_sha256=sha(ROOT/'maintenance/validation/userland-fix5-20261104/validation.json'),
 software_wayland=window, software_session=session, independent_software_pixels_verified=True,
 software_rejected_as_hardware=rejected, staging_and_dependency_resolution_verified=True,
 no_rpath_runpath=True, driver_installed=False, driver_loaded=False, current_services=services,
 watchdog_state=watchdog, hardware_watchdog_reset_proven=False,
 boot_id=Path('/proc/sys/kernel/random/boot_id').read_text().strip(), last_runtime_test='20261104-200750',
 last_runtime_recovery_verified=True, fresh_root_backup_and_boot_audit_required=True,
 ready_for_fresh_backup_entrypoint=True, s30_v8_tested=False, s30_v6_display_bridge_hardware_exercised=False,
 full_plasma_tested=False, xwayland_tested=False, vendor_binary_modified=False, abi_version_check_bypassed=False)
(archive/'readiness.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
