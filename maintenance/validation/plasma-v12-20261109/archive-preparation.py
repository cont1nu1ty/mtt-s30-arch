from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'maintenance/recovery'))
import desktop_support as desktop
from workload_support import last_json

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

stage = ROOT / 'work/v12-cpu-final'
bundle = ROOT / 'builds' / desktop.BUNDLE_DIRECTORY
second = ROOT / 'work/v12-rebuild-final'
out = ROOT / 'maintenance/validation/plasma-v12-20261109'
out.mkdir()
software = out / 'software'; software.mkdir()
session = json.loads((stage / 'desktop-session-result.json').read_text())
assert session['passed'] and not session['forced_kill'] and session['kwin_exit'] == 15
assert session['plasma_shell']['passed'] and session['xwayland']['passed']
assert session['plasma_shell']['panel_layout_change_and_restore']
assert session['plasma_shell']['exit_codes']['plasma.log']['code'] == 0
assert session['xwayland']['server']['setup_helper_verified']
assert session['xwayland']['client_exit'] == 0
assert session['completed_window_cycles'] == 5
colors = [bytes(v) for v in ((255,0,0,255),(0,255,0,255),(0,0,255,255),(255,255,255,255))]
pixels = {}
for name, frame in (('wayland.rgba',59), ('qt.rgba',11), ('x11.rgba',11)):
    expected = b''.join(colors[((x//16)+3*(y//16)+frame)%4] for y in range(192) for x in range(256))
    assert (stage/name).read_bytes() == expected, name
    pixels[name] = {'matched': True, 'pixels': 256*192, 'sha256': sha(stage/name)}
from PIL import Image
assert Image.open(stage/'qt.rgba.png').convert('RGBA').tobytes() == (stage/'qt.rgba').read_bytes()
private_processes = []
for proc in Path('/proc').iterdir():
    if not proc.name.isdecimal():
        continue
    try:
        values = (proc/'environ').read_bytes().split(b'\0')
        if any(v in values for v in (os.fsencode('XDG_RUNTIME_DIR='+str(stage/'desktop-runtime')),
                                    os.fsencode('HOME='+str(stage/'desktop-home')))):
            private_processes.append(int(proc.name))
    except (PermissionError, FileNotFoundError, ProcessLookupError):
        pass
assert not private_processes, private_processes
desktop.verify_host(); desktop.verify_bundle(bundle)
for name in desktop.USERLAND_FILES | {'manifest.json'}:
    assert (bundle/name).read_bytes() == (second/name).read_bytes(), name
base = ROOT/'builds/desktop-applications-v11-20261109'
assert sha(base/'manifest.json') == '8b6f7a9f028bac894b34a206b17a9755470e45b88e5e2b923122eab64cd18f64'
for name, item in json.loads((base/'manifest.json').read_text())['files'].items():
    assert sha(base/name) == item['sha256'], name
tests = (ROOT/'work/v12-tests-final.log').read_text()
assert re.search(r'Ran 107 tests in [\d.]+s\s+OK', tests)
kwin = ROOT/'work/p12-kwin-session-build'
format_tests = json.loads((kwin/'format-regression/results.json').read_text())
guards = json.loads((kwin/'startup-guards/results.json').read_text())
assert format_tests['passed'] and len(format_tests['cases']) == 35
assert format_tests['library_sha256'] == sha(bundle/'kwin/libkwin.so.6')
assert guards['passed'] and len(guards['cases']) == 5
assert not Path('/sys/module/mtgpu').exists()
assert subprocess.check_output(['systemctl','is-active','display-manager'],text=True).strip() == 'active'
files = ['compatible-protocol.log','desktop-session-result.json','kwin-support-after.log',
         'kwin-support-before.log','kwin.log','plasma-activities.log','plasma-after.json',
         'plasma-before.json','plasma-kio.log','plasma-process-maps.log','plasma-result.json',
         'plasma.log','private-xwayland.json','qt-client.log','qt.rgba','qt.rgba.png',
         'validation.log','vendor-protocol.log','wayland-client.log','wayland.rgba',
         'x11-client.log','x11.rgba','xwayland-result.json']
for name in files:
    shutil.copyfile(stage/name, software/name)
shutil.copyfile(bundle/'manifest.json', out/'desktop-manifest.json')
shutil.copyfile(ROOT/'work/v12-tests-final.log',out/'flow-tests.log')
shutil.copyfile(kwin/'result.json',out/'kwin-build-result.json')
shutil.copyfile(kwin/'kwin-private-xwayland-startup.patch',out/'kwin-private-xwayland-startup.patch')
shutil.copyfile(kwin/'format-regression/results.json',out/'kwin-format-tests.json')
shutil.copyfile(kwin/'startup-guards/results.json',out/'kwin-startup-guards.json')
shutil.copyfile(ROOT/'work/x12/validation.json',out/'x11-independent-controls.json')
shutil.copyfile(ROOT/'work/p12/validation.json',out/'plasma-earlier-controls.json')
shutil.copyfile(__file__, out/'archive-preparation.py')
sources = ['maintenance/desktop/'+name for name in ('build-plasma-checks.py','build-kwin-session-compat.py',
            'validate-userland.py','qt-check.cpp','x11-check.cpp','build-x11-check.py')]
sources += [str(p.relative_to(ROOT)) for p in sorted((ROOT/'maintenance/recovery').glob('*.py'))]
data = {
    'verified_utc': datetime.now(timezone.utc).isoformat(),
    'profile': desktop.PROFILE, 'status': 'prepared; S30 Plasma/XWayland hardware run pending',
    'hardware_tested': False, 'latest_hardware_pass': '20261109-160826 (v11)',
    'manifest_sha256': desktop.MANIFEST_SHA, 'bundle': str(bundle),
    'byte_identical_second_build': True, 'payload_file_count': len(desktop.USERLAND_FILES),
    'unchanged_v11_bundle_verified': True,
    'host_package_pins_verified': desktop.REVIEWED_DESKTOP_PACKAGES,
    'staging_and_runtime_dependencies_passed': True,
    'recovery_flow_tests': 107, 'process_group_cleanup_tests_included': 5,
    'kwin_final_library_format_tests': 35, 'kwin_startup_guard_tests': 5,
    'software_session_passed': True, 'software_wayland': last_json(stage/'wayland-client.log'),
    'software_qt': session['qt_quick_client'], 'software_plasma': session['plasma_shell'],
    'software_xwayland': session['xwayland'], 'independent_pixels': pixels,
    'qt_png_matches_rgba': True, 'no_remaining_private_runtime_processes': True,
    'software_presentation_flags_are_not_hardware_evidence': True,
    'full_login_session_tested': False, 's30_plasma_tested': False, 's30_xwayland_tested': False,
    'scanout_pixels_captured': False, 'watchdog_reset_proven': False,
    'session_total_timeout_seconds': desktop.SESSION_TIMEOUT,
    'session_timeout_cleanup_max_additional_seconds': 4,
    'supervisor_reboot_seconds': 180, 'fallback_reboot_seconds': 210,
    'fresh_root_backup_and_boot_audit_pending': True,
    'module_sha256': '6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff',
    'current_boot_id': Path('/proc/sys/kernel/random/boot_id').read_text().strip(),
    'current_kernel': os.uname().release, 'module_loaded': False, 'display_manager_active': True,
    'system_install_or_boot_change_performed': False,
    'local_failure_fixed': {'stage': 'work/v12-cpu', 'cause': 'Qt readback completed before the last frameSwapped signal; now waits within the original watchdog before app cleanup.'},
    'earlier_control_scope': 'Standalone Plasma controls precede private X endpoint metadata; final integrated run above uses final manifest. X11 source matches unchanged C++ source.',
    'sources_sha256': {name: sha(ROOT/name) for name in sources},
}
(out/'validation.json').write_text(json.dumps(data,indent=2)+'\n')
hashes = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()}
(out/'evidence-sha256.json').write_text(json.dumps(hashes,indent=2)+'\n')
print(json.dumps({'evidence':str(out),'files_hashed':len(hashes),'manifest':desktop.MANIFEST_SHA,'tests':107,'software_passed':True},indent=2))
