"""Independent, read-only byte/protocol cross-check of the v10 export."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path('/home/bull/Documents/mtt-s30-arch')
EXPORT = Path('/var/tmp/mtt-s30-results-20261109-153310-46qtcw6l')
STAGE = Path('/var/lib/mtt-s30-test/20261109-153310/test')
OUT = Path(__file__).parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(name):
    return json.loads((EXPORT / name).read_text())


def result(name):
    return json.loads((EXPORT / name).read_text().strip().splitlines()[-1])


config = read_json('config.json')
manifest = read_json('desktop-manifest.json')
workloads = read_json('workload-manifest.json')
session = read_json('desktop-session-result.json')
desktop = read_json('desktop-result.json')
probe = read_json('probe-result.json')
assert manifest['profile'] == config['profile'] == 'kwin-wayland-v10'
assert sha(EXPORT / 'desktop-manifest.json') == config['desktop_manifest_sha256']
assert sha(EXPORT / 'workload-manifest.json') == config['workload_manifest_sha256']
bundle = ROOT / 'builds/desktop-userland-fix9-20261109'
assert (bundle / 'manifest.json').read_bytes() == (EXPORT / 'desktop-manifest.json').read_bytes()
for name, detail in manifest['files'].items():
    assert sha(bundle / name) == detail['sha256']
    assert (bundle / name).stat().st_size == detail['size']
for name, field in [('test-once.py', 'script_sha256'), ('desktop_support.py', 'desktop_support_sha256'),
                    ('workload_support.py', 'workload_support_sha256')]:
    assert sha(ROOT / 'maintenance/recovery' / name) == config[field]

images = {}
palette = bytes.fromhex('ff0000ff00ff00ff0000ffffffffffff')
for filename, width, height, frame in [('render.rgba', 128, 96, 7),
                                      ('egl-gbm.rgba', 256, 192, 7),
                                      ('wayland.rgba', 256, 192, 59)]:
    actual = (EXPORT / filename).read_bytes()
    expected = bytearray()
    for y in range(height):
        for x in range(width):
            color = (x // 16 + 3 * (y // 16) + frame) % 4
            expected.extend(palette[4 * color:4 * color + 4])
    assert actual == expected, filename
    images[filename] = {'pixels': width * height, 'bytes': len(actual), 'frame': frame,
                        'sha256': sha(EXPORT / filename), 'independent_match': True}

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

client = (EXPORT / 'wayland-client.log').read_text()
client_result = result('wayland-client.log')
assert client_result == desktop['wayland_client']
assert client_result['passed'] and client_result['mode'] == 'wayland-s30'
assert client_result['renderer'] == 'MTT S30' and client_result['vendor'] == 'MOORE THREADS'
assert client_result['frames'] == client_result['presented'] == client_result['hardware_presentations'] == 60
assert client_result['pixels_checked'] == 2949120 and client_result['mismatches'] == client_result['discarded'] == 0
assert client_result['presentation_flags_all'] == 7
libraries = re.findall(r'^Graphics library: (.+)$', client, re.M)
assert set(libraries) == {str(STAGE / 'desktop/egl/libEGL_mesa.so.0'),
                          str(STAGE / 'desktop/client-dri/mtgpu_dri.so'),
                          str(STAGE / 'desktop/client-dri/musa_dri.so')}
assert 'GL renderer: MTT S30' in client and 'GL vendor: MOORE THREADS' in client
assert 'free(): double free' not in client and 'Pixel mismatch' not in client

requests = 0
pending = {}
callbacks = []
surface = None
for line in client.splitlines():
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
        assert not callbacks or stamp > callbacks[-1]
        callbacks.append(stamp)
assert requests == len(callbacks) == 60 and not pending
assert not re.search(r'wp_presentation_feedback#\d+\.discarded\(', client)
assert len(re.findall(r'wp_presentation_feedback#\d+\.presented\(', client)) == 60

last_present = client.rfind('.presented(')
cleanup = client[last_present:]
for event in ['wl_buffer#16.destroy()', 'wl_buffer#17.destroy()', 'xdg_toplevel#8.destroy()',
              'xdg_surface#7.destroy()', 'wl_surface#3.destroy()', 'wp_presentation#5.destroy()',
              'xdg_wm_base#6.destroy()', 'wl_display#1.sync(', 'wl_callback#13.done(10)']:
    assert event in cleanup, event
assert cleanup.index('wl_surface#3.destroy()') < cleanup.index('wl_display#1.sync(') < cleanup.index('wl_callback#13.done(10)') < cleanup.index('"passed":true')
assert session['client_exit'] == 0 and session['passed'] and session['checks_passed']
assert session['private_client_dri_verified'] and session['mtgpu_gles_dispatch_selected']
assert session['kwin_exit'] == 15 and session['termination_requested'] and not session['forced_kill']
assert session['compositor_faults'] == []
assert probe['desktop'] == desktop and probe['desktop_session'] == session and probe['passed']
for name in ['kwin-support-before.log', 'kwin-support-after.log']:
    support = (EXPORT / name).read_text()
    for line in ['Name: HDMI-A-1', 'Enabled: 1', 'Geometry: 0,0,1920x1080',
                 'OpenGL renderer string: MTT S30', 'OpenGL platform interface: EGL']:
        assert line in support

report = {'test': '20261109-153310', 'independently_verified': True, 'export': str(EXPORT),
          'desktop_manifest_sha256': sha(EXPORT / 'desktop-manifest.json'),
          'verified_bundle_files': len(manifest['files']), 'loaded_libraries': libraries,
          'saved_images': images, 'video_bytes_compared': len(video), 'video_reference_match': True,
          'video_fresh_cpu_decode_match': True, 'video_sha256': hashlib.sha256(video).hexdigest(),
          'wayland_client': client_result, 'matched_requests_and_callbacks': requests,
          'first_present_ns': callbacks[0], 'last_present_ns': callbacks[-1],
          'strictly_increasing_present_times': True, 'all_presentation_flags': 7,
          'protocol_cleanup_and_roundtrip': True, 'client_exit': session['client_exit'],
          'kwin_alive_after_client': session['checks_passed'], 'kwin_orderly_exit': True,
          'compositor_faults': session['compositor_faults'],
          'source_cleanup_gate': 'egl-check.c:208-216 before final success JSON',
          'scope': 'Saved final frame independently checked for each render path, all H264 frames compared; live earlier frame correctness comes from the pinned client checks and final successful result. Scanout pixels were not captured.'}
(OUT / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
