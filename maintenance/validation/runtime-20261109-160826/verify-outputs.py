"""Independent read-only review of exported v11 bytes, protocol and provenance."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
from PIL import Image

ROOT = Path('/home/bull/Documents/mtt-s30-arch')
EXPORT = Path('/var/tmp/mtt-s30-results-20261109-160826')
STAGE = Path('/var/lib/mtt-s30-test/20261109-160826/test')
OUT = Path(__file__).parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(name):
    return json.loads((EXPORT / name).read_text())


def last_result(name):
    return json.loads((EXPORT / name).read_text().splitlines()[-1])


config = read_json('config.json')
manifest = read_json('desktop-manifest.json')
workloads = read_json('workload-manifest.json')
session = read_json('desktop-session-result.json')
desktop = read_json('desktop-result.json')
probe = read_json('probe-result.json')
recovery = read_json('recovery-result.json')
assert manifest['profile'] == config['profile'] == 'kwin-wayland-v11'
assert sha(EXPORT / 'desktop-manifest.json') == config['desktop_manifest_sha256'] == '8b6f7a9f028bac894b34a206b17a9755470e45b88e5e2b923122eab64cd18f64'
assert sha(EXPORT / 'workload-manifest.json') == config['workload_manifest_sha256']
bundle = ROOT / 'builds/desktop-applications-v11-20261109'
assert (bundle / 'manifest.json').read_bytes() == (EXPORT / 'desktop-manifest.json').read_bytes()
assert len(manifest['files']) == 9
for name, detail in manifest['files'].items():
    assert sha(bundle / name) == detail['sha256']
    assert (bundle / name).stat().st_size == detail['size']
for name, field in [('test-once.py', 'script_sha256'), ('desktop_support.py', 'desktop_support_sha256'),
                    ('workload_support.py', 'workload_support_sha256')]:
    assert sha(ROOT / 'maintenance/recovery' / name) == config[field]
for name in ('egl-check.c', 'qt-check.cpp'):
    assert sha(ROOT / 'maintenance/desktop' / name) == manifest['source_sha256'][name]
assert all(not entry['tail_only'] for entry in recovery['copied'])
for entry in recovery['copied']:
    assert (EXPORT / entry['name']).stat().st_size == entry['source_bytes']

images = {}
palette = bytes.fromhex('ff0000ff00ff00ff0000ffffffffffff')
for filename, width, height, frame in [('render.rgba', 128, 96, 7),
                                      ('egl-gbm.rgba', 256, 192, 7),
                                      ('wayland.rgba', 256, 192, 59),
                                      ('qt.rgba', 256, 192, 11)]:
    actual = (EXPORT / filename).read_bytes()
    expected = bytearray()
    for y in range(height):
        for x in range(width):
            color = (x // 16 + 3 * (y // 16) + frame) % 4
            expected.extend(palette[4 * color:4 * color + 4])
    assert actual == expected, filename
    images[filename] = {'pixels': width * height, 'bytes': len(actual), 'frame': frame,
                        'sha256': sha(EXPORT / filename), 'independent_match': True}
with Image.open(EXPORT / 'qt.rgba.png') as image:
    assert image.size == (256, 192) and image.convert('RGBA').tobytes() == (EXPORT / 'qt.rgba').read_bytes()

reference = ROOT / 'builds/workloads-20261030/reference.nv12'
clip = ROOT / 'builds/workloads-20261030/clip.h264'
assert sha(reference) == workloads['files']['reference.nv12']['sha256']
assert sha(clip) == workloads['files']['clip.h264']['sha256']
video = (EXPORT / 'decoded.nv12').read_bytes()
assert video == reference.read_bytes()
decoded = subprocess.run(['ffmpeg', '-v', 'error', '-threads', '1', '-c:v', 'h264',
                          '-i', str(clip), '-map', '0:v:0', '-pix_fmt', 'nv12', '-f', 'rawvideo', 'pipe:1'],
                         capture_output=True, check=True, timeout=15)
assert decoded.stdout == video
assert len(video) == 320 * 192 * 3 // 2 * 48 == 4423680

expected_libraries = {str(STAGE / 'desktop/egl/libEGL_mesa.so.0'),
                      str(STAGE / 'desktop/client-dri/mtgpu_dri.so'),
                      str(STAGE / 'desktop/client-dri/musa_dri.so')}
client = (EXPORT / 'wayland-client.log').read_text()
client_result = last_result('wayland-client.log')
assert client_result == desktop['wayland_client']
assert client_result['passed'] and client_result['mode'] == 'wayland-s30'
assert client_result['renderer'] == 'MTT S30' and client_result['vendor'] == 'MOORE THREADS'
assert client_result['frames'] == client_result['presented'] == client_result['hardware_presentations'] == 300
assert client_result['pixels_checked'] == 14745600 and client_result['mismatches'] == client_result['discarded'] == 0
assert client_result['presentation_flags_all'] == 7
assert client_result['completed_cycles'] == 5 and client_result['frames_per_cycle'] == 60
assert 'free(): double free' not in client and 'Pixel mismatch' not in client

all_callbacks = []
cycles = []
previous_end = 0
markers = list(re.finditer(r'^Lifecycle completed (\d+)/(\d+) frames=(\d+) presented=(\d+)$', client, re.M))
assert len(markers) == 5
for number, marker in enumerate(markers, 1):
    assert tuple(map(int, marker.groups())) == (number, 5, 60, 60)
    chunk = client[previous_end:marker.start()]
    previous_end = marker.end()
    assert set(re.findall(r'^Graphics library: (.+)$', chunk, re.M)) == expected_libraries
    assert 'GL renderer: MTT S30' in chunk and 'GL vendor: MOORE THREADS' in chunk
    requests = 0
    pending = {}
    callbacks = []
    surface = None
    for line in chunk.splitlines():
        request = re.search(r'wp_presentation#\d+\.feedback\(wl_surface#(\d+), new id wp_presentation_feedback#(\d+)\)', line)
        if request:
            surface_id, feedback_id = request.groups()
            surface = surface or surface_id
            assert surface == surface_id and feedback_id not in pending
            pending[feedback_id] = requests
            requests += 1
        presented = re.search(r'wp_presentation_feedback#(\d+)\.presented\(([^)]+)\)', line)
        if presented:
            feedback_id, arguments = presented.groups()
            args = list(map(int, arguments.split(',')))
            assert len(args) == 7 and feedback_id in pending
            assert pending.pop(feedback_id) == len(callbacks)
            hi, low, nano, refresh, seq_hi, seq_low, flags = args
            stamp = ((hi << 32) | low) * 1000000000 + nano
            assert 0 <= nano < 1000000000 and flags == 7
            assert not all_callbacks or stamp > all_callbacks[-1]
            callbacks.append(stamp)
            all_callbacks.append(stamp)
    assert requests == len(callbacks) == 60 and not pending
    assert not re.search(r'wp_presentation_feedback#\d+\.discarded\(', chunk)
    assert len(re.findall(r'wp_presentation_feedback#\d+\.presented\(', chunk)) == 60
    cleanup = chunk[chunk.rfind('.presented('):]
    assert f'wl_surface#{surface}.destroy()' in cleanup
    for kind in ('wl_buffer', 'xdg_toplevel', 'xdg_surface', 'wp_presentation', 'xdg_wm_base'):
        assert re.search(kind + r'#\d+\.destroy\(\)', cleanup), (number, kind)
    sync = re.search(r'wl_display#1\.sync\(new id wl_callback#(\d+)\)', cleanup)
    assert sync and cleanup.index(f'wl_surface#{surface}.destroy()') < sync.start()
    done = re.search(r'wl_callback#' + sync[1] + r'\.done\(\d+\)', cleanup[sync.end():])
    assert done, number
    cycles.append({'cycle': number, 'matched_presentations': len(callbacks), 'surface_id': surface,
                   'all_flags': 7, 'cleanup_roundtrip_before_completion': True,
                   'first_present_ns': callbacks[0], 'last_present_ns': callbacks[-1]})
assert len(all_callbacks) == 300
assert client[previous_end:].strip() == json.dumps(client_result, separators=(',', ':'))

qt_log = (EXPORT / 'qt-client.log').read_text()
qt_result = last_result('qt-client.log')
assert qt_result == desktop['qt_quick_client'] == session['qt_quick_client']
assert qt_result['passed'] and qt_result['mode'] == 'qt-wayland-s30' and qt_result['renderer'] == 'MTT S30'
assert qt_result['vendor'] == 'MOORE THREADS' and qt_result['opengles'] and qt_result['graphics_api'] == 'OpenGL'
assert qt_result['frames'] == 12 and qt_result['pixels_checked'] == 589824 and qt_result['mismatches'] == 0
assert qt_result['swapped'] == 12 and qt_result['window_destroyed']
assert set(re.findall(r'^Graphics library: (.+)$', qt_log, re.M)) == expected_libraries
qt_cleanup = qt_log[qt_log.rfind('Graphics library:'):]
for kind in ('wl_buffer', 'xdg_toplevel', 'xdg_surface', 'wl_surface', 'xdg_wm_base', 'wl_fixes'):
    assert re.search(kind + r'#\d+\.destroy\(\)', qt_cleanup), kind
assert qt_cleanup.rfind('.destroy()') < qt_cleanup.rfind('{"frames":12')
assert 'free(): double free' not in qt_log and 'Qt Quick pixel mismatch' not in qt_log
assert session['client_exit'] == session['qt_client_exit'] == 0
assert session['passed'] and session['checks_passed'] and session['completed_window_cycles'] == 5
assert session['private_client_dri_verified'] and session['mtgpu_gles_dispatch_selected']
assert all(session['qt_compatibility'].values())
assert session['kwin_exit'] == 15 and session['termination_requested'] and not session['forced_kill']
assert session['compositor_faults'] == []
assert probe['desktop'] == desktop and probe['desktop_session'] == session and probe['passed']
assert all(code == 0 for code in probe['checks'].values())
for name in ['kwin-support-before.log', 'kwin-support-after.log']:
    support = (EXPORT / name).read_text()
    for line in ['Name: HDMI-A-1', 'Enabled: 1', 'Geometry: 0,0,1920x1080',
                 'OpenGL renderer string: MTT S30', 'OpenGL platform interface: EGL']:
        assert line in support
assert recovery['reboot_observed'] and recovery['original_boot_and_efi_verified']
assert recovery['client_core']['status'] == recovery['qt_client_core']['status'] == 'not_found'

report = {'test': '20261109-160826', 'independently_verified': True, 'export': str(EXPORT),
          'desktop_manifest_sha256': sha(EXPORT / 'desktop-manifest.json'),
          'verified_bundle_files': len(manifest['files']), 'client_source_hashes_verified': True,
          'loaded_libraries_per_client': sorted(expected_libraries), 'saved_images': images,
          'qt_png_matches_rgba': True, 'video_bytes_compared': len(video), 'video_reference_match': True,
          'video_fresh_cpu_decode_match': True, 'video_sha256': hashlib.sha256(video).hexdigest(),
          'wayland_client': client_result, 'cycles': cycles, 'matched_requests_and_callbacks': len(all_callbacks),
          'strictly_increasing_present_times_across_cycles': True, 'all_presentation_flags': 7,
          'qt_quick_client': qt_result, 'qt_application_protocol_teardown_precedes_last_success_json': True,
          'client_exit': session['client_exit'], 'qt_client_exit': session['qt_client_exit'],
          'kwin_alive_after_clients': session['checks_passed'], 'kwin_orderly_exit': True,
          'compositor_faults': session['compositor_faults'], 'client_core_records': 'none for either client',
          'all_exported_files_complete': True,
          'scope': 'Saved final frame independently checked for each render path; all H264 bytes compared. Earlier frame correctness relies on pinned client checks plus successful exits. Qt swaps/readback are not presentation feedback. Physical scanout pixels, complete Plasma, XWayland and long-duration stability were not tested.'}
(OUT / 'output-verification.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
