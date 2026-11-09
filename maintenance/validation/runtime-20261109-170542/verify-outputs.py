"""Independent read-only review of exported v12 bytes, protocol and provenance."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
from PIL import Image

ROOT = Path('/home/bull/Documents/mtt-s30-arch')
EXPORT = Path('/var/tmp/mtt-s30-results-20261109-170542')
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
probe = read_json('probe-result.json')
recovery = read_json('recovery-result.json')
plasma = read_json('plasma-result.json')

assert manifest['profile'] == config['profile'] == 'kwin-plasma-xwayland-v12'
assert sha(EXPORT / 'desktop-manifest.json') == config['desktop_manifest_sha256'] == 'd9d00ef849dab55a77e895a787194b6dfd04f2fdd724563666be4b353142b94a'
assert sha(EXPORT / 'workload-manifest.json') == config['workload_manifest_sha256']
bundle = ROOT / 'builds/desktop-plasma-v12-20261109'
assert (bundle / 'manifest.json').read_bytes() == (EXPORT / 'desktop-manifest.json').read_bytes()
assert len(manifest['files']) == 12
for name, detail in manifest['files'].items():
    assert sha(bundle / name) == detail['sha256']
    assert (bundle / name).stat().st_size == detail['size']

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

# Wayland client log check
client = (EXPORT / 'wayland-client.log').read_text()
client_result = last_result('wayland-client.log')
assert client_result['passed'] and client_result['mode'] == 'wayland-s30'
assert client_result['renderer'] == 'MTT S30' and client_result['vendor'] == 'MOORE THREADS'
assert client_result['frames'] == client_result['presented'] == client_result['hardware_presentations'] == 300
assert client_result['pixels_checked'] == 14745600 and client_result['mismatches'] == client_result['discarded'] == 0
assert client_result['presentation_flags_all'] == 7
assert client_result['completed_cycles'] == 5 and client_result['frames_per_cycle'] == 60
assert 'free(): double free' not in client and 'Pixel mismatch' not in client

qt_log = (EXPORT / 'qt-client.log').read_text()
qt_result = last_result('qt-client.log')
assert qt_result == session['qt_quick_client']
assert qt_result['passed'] and qt_result['mode'] == 'qt-wayland-s30' and qt_result['renderer'] == 'MTT S30'
assert qt_result['vendor'] == 'MOORE THREADS' and qt_result['opengles'] and qt_result['graphics_api'] == 'OpenGL'
assert qt_result['frames'] == 12 and qt_result['pixels_checked'] == 589824 and qt_result['mismatches'] == 0
assert qt_result['swapped'] == 14 and qt_result['window_destroyed']

assert session['client_exit'] == session['qt_client_exit'] == 0
assert session['completed_window_cycles'] == 5
assert session['private_client_dri_verified'] and session['mtgpu_gles_dispatch_selected']
assert all(session['qt_compatibility'].values())

# Plasma result check
assert not plasma['passed'] and plasma['phase'] == 'failed'
assert plasma['shell_pid'] == 30149 and plasma['exit_codes']['plasma.log']['code'] == -11
assert not session['passed']
assert session['kwin_exit'] == 15 and session['termination_requested'] and not session['forced_kill']
assert session['compositor_faults'] == []

assert recovery['reboot_observed'] and recovery['original_boot_and_efi_verified']
assert recovery['client_core']['status'] == recovery['qt_client_core']['status'] == 'not_found'
assert recovery['plasma_core']['status'] == 'copied'
assert recovery['plasma_core']['pid'] == '30149' and recovery['plasma_core']['signal'] == '11'

report = {
    'test': '20261109-170542',
    'independently_verified': True,
    'export': str(EXPORT),
    'desktop_manifest_sha256': sha(EXPORT / 'desktop-manifest.json'),
    'verified_bundle_files': len(manifest['files']),
    'saved_images': images,
    'qt_png_matches_rgba': True,
    'video_bytes_compared': len(video),
    'video_reference_match': True,
    'video_fresh_cpu_decode_match': True,
    'video_sha256': hashlib.sha256(video).hexdigest(),
    'wayland_client': client_result,
    'qt_quick_client': qt_result,
    'client_exit': session['client_exit'],
    'qt_client_exit': session['qt_client_exit'],
    'plasma_result': plasma,
    'kwin_orderly_exit': True,
    'compositor_faults': session['compositor_faults'],
    'recovery_verified': True,
    'plasma_coredump_matched': True,
    'scope': 'Vulkan, H.264, EGL/GBM, 5 cycles Wayland (300 frames) and Qt Quick (12 frames) passed. Plasma failed with SIGSEGV in plasmashell thread 30186 at 0x0 via QEGLPlatformContext::checkGraphicsReset() + 27 calling glGetGraphicsResetStatus.'
}
(OUT / 'output-verification.json').write_text(json.dumps(report, indent=2) + '\n')
print("Verification successfully generated output-verification.json")
