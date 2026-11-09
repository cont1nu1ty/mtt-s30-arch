"""Bounded, hash-pinned workload staging and independent output checks."""
import hashlib
import json
from pathlib import Path
import shutil
import stat

PROFILE = 'render-decode-v1'
FILES = {'vk-offscreen', 'h264-check', 'clip.h264', 'reference.nv12'}
VIDEO_BYTES = 320 * 192 * 3 // 2 * 48


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def verify_bundle(directory, manifest_sha):
    directory = Path(directory)
    manifest = directory / 'manifest.json'
    require(stat.S_ISREG(manifest.lstat().st_mode), 'Manifest must be a regular file.')
    require(manifest.stat().st_size < 65536, 'Manifest exceeds limit.')
    require(digest(manifest) == manifest_sha, 'Workload manifest checksum changed.')
    data = json.loads(manifest.read_text())
    require(data.get('profile') == PROFILE and set(data.get('files', {})) == FILES,
            'Unexpected workload profile or file set.')
    for name, metadata in data['files'].items():
        path = directory / name
        info = path.lstat()
        require(stat.S_ISREG(info.st_mode) and 0 < info.st_size <= 8 * 1024 * 1024,
                'Unexpected workload file type or size: ' + name)
        require(info.st_size == metadata['size'] and digest(path) == metadata['sha256'],
                'Workload file checksum changed: ' + name)
    require((directory / 'reference.nv12').stat().st_size == VIDEO_BYTES,
            'Unexpected reference size.')
    return data


def stage_bundle(source, destination, manifest_sha):
    verify_bundle(source, manifest_sha)
    destination = Path(destination)
    destination.mkdir(mode=0o700)
    for name in sorted(FILES | {'manifest.json'}):
        target = destination / name
        shutil.copyfile(Path(source) / name, target)
        target.chmod(0o500 if name in {'vk-offscreen', 'h264-check'} else 0o400)
    # Re-read destination to catch a source changing while being copied.
    verify_bundle(destination, manifest_sha)


def last_json(path):
    lines = Path(path).read_text().splitlines()
    require(bool(lines), 'Workload produced no result.')
    return json.loads(lines[-1])


def verify_render(result, pixels):
    require(result == {'passed': True, 'mode': 's30', 'frames': 8,
                       'pixels_checked': 98304, 'mismatches': 0},
            'Rendering did not pass on the S30 device.')
    require(len(pixels) == 128 * 96 * 4, 'Rendering output is incomplete.')
    colors = [bytes((255, 0, 0, 255)), bytes((0, 255, 0, 255)),
              bytes((0, 0, 255, 255)), bytes((255, 255, 255, 255))]
    # Check the saved final frame independently of the executable's verdict.
    expected = b''.join(colors[(column + 3 * row + 7) % 4] * 16
                        for row in range(6) for _ in range(16) for column in range(8))
    require(pixels == expected, 'Saved rendering pixels differ from reference.')


def verify_video(result, decoded, reference):
    require(result == {'passed': True, 'mode': 'vaapi', 'frames': 48,
                       'hardware_frames': 48, 'bad_frames': 0,
                       'different_bytes': 0, 'max_abs_error': 0},
            'Video did not pass for all 48 hardware frames.')
    require(Path(decoded).stat().st_size == VIDEO_BYTES and
            Path(reference).stat().st_size == VIDEO_BYTES,
            'Video output/reference has the wrong frame count or size.')
    require(digest(decoded) == digest(reference), 'Decoded video differs from CPU reference.')


def run_workloads(stage, render_node, env, command, check_kernel, manifest_sha):
    stage = Path(stage)
    bundle = stage / 'workloads'
    verify_bundle(bundle, manifest_sha)
    require(render_node.startswith('/dev/dri/renderD') and
            Path(render_node).parent == Path('/dev/dri'), 'Invalid render device path.')
    require(command('render-workload', [str(bundle / 'vk-offscreen'), str(stage / 'render.rgba')],
                    30, env) == 0, 'GPU rendering workload failed.')
    rendered = last_json(stage / 'render-workload.log')
    verify_render(rendered, (stage / 'render.rgba').read_bytes())
    check_kernel()
    require(command('video-workload', [str(bundle / 'h264-check'), render_node,
                    str(bundle / 'clip.h264'), str(bundle / 'reference.nv12'),
                    str(stage / 'decoded.nv12')], 30, env) == 0, 'VA-API decoding workload failed.')
    decoded = last_json(stage / 'video-workload.log')
    verify_video(decoded, stage / 'decoded.nv12', bundle / 'reference.nv12')
    check_kernel()
    result = {'profile': PROFILE, 'passed': True, 'render': rendered, 'video': decoded,
              'render_sha256': digest(stage / 'render.rgba'),
              'decoded_sha256': digest(stage / 'decoded.nv12'),
              'manifest_sha256': manifest_sha, 'accelerated_desktop_tested': False}
    (stage / 'workload-result.json').write_text(json.dumps(result, indent=2) + '\n')
    return result
