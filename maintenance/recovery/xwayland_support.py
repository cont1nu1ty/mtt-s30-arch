"""Authenticated private XWayland endpoint and fail-closed GLX validation."""
import json
import os
from pathlib import Path
import re
import secrets
import socket
import stat
import struct
import subprocess
from workload_support import require, last_json

FILES = ('x11-client.log', 'x11.rgba', 'xwayland-result.json', 'xwayland-process-maps.log', 'private-xwayland.json')
SETUP_OK = 'MTT validation: Xwayland setup helper completed "/usr/lib/plasma-setup-xwayland" exitCode 0 normalExit true'
FALLBACK = re.compile(r'failed to initialize glamor|falling back to sw|disabling glamor|'
                      r'Refusing to try glamor|XWAYLAND_NO_GLAMOR|glamor.*GL_OUT_OF_MEMORY', re.I)


def endpoint(stage):
    """Bind only an unused abstract socket; never remove another X server's files."""
    stage = Path(stage)
    for number in range(100, 200):
        if Path(f'/tmp/.X11-unix/X{number}').exists() or Path(f'/tmp/.X{number}-lock').exists():
            continue
        listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            listener.bind(f'\0/tmp/.X11-unix/X{number}')
            listener.listen(16)
        except OSError:
            listener.close()
            continue
        auth = stage / 'desktop-runtime/xauthority'
        try:
            # Xau record: FamilyWild, address, display number, protocol, cookie.
            fields = (b'', str(number).encode(), b'MIT-MAGIC-COOKIE-1', secrets.token_bytes(16))
            data = struct.pack('!H', 65535) + b''.join(struct.pack('!H', len(v)) + v for v in fields)
            fd = os.open(auth, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
            with os.fdopen(fd, 'wb') as stream:
                stream.write(data)
            endpoint_file = stage / 'private-xwayland.json'
            with endpoint_file.open('x') as stream:
                json.dump({'display': ':' + str(number), 'xauthority': str(auth)}, stream)
            endpoint_file.chmod(0o600)
        except Exception:
            listener.close()
            raise
        return listener, ':' + str(number), str(auth)
    raise RuntimeError('No unused private XWayland display socket.')


def client_env(stage, base, display, auth, software=False):
    env = dict(base, DISPLAY=display, XAUTHORITY=auth)
    for key in ('WAYLAND_DEBUG', 'MTT_S30_WAYLAND_GLAPI', 'LIBGL_ALWAYS_INDIRECT', 'LD_PRELOAD'):
        env.pop(key, None)
    if not software:
        for key in ('LIBGL_ALWAYS_SOFTWARE', 'MESA_LOADER_DRIVER_OVERRIDE', 'GALLIUM_DRIVER'):
            env.pop(key, None)
        vendor = Path(stage) / 'vendor/usr/lib/x86_64-linux-gnu'
        env.update(LD_LIBRARY_PATH=str(vendor), LIBGL_DRIVERS_PATH=str(vendor / 'dri'),
                   __GLX_VENDOR_LIBRARY_NAME='mtgpu')
    else:
        env.pop('LD_LIBRARY_PATH', None)
        env.pop('LIBGL_DRIVERS_PATH', None)
        env.pop('GBM_BACKEND', None)
        env.pop('GBM_BACKENDS_PATH', None)
        env.update(LIBGL_ALWAYS_SOFTWARE='1', __GLX_VENDOR_LIBRARY_NAME='mesa')
    return env


def validate_result(result, pixels, software=False):
    required = ('passed', 'direct', 'xwayland_extension', 'desktop_opengl',
                'window_destroyed', 'context_destroyed', 'display_closed')
    require(all(result.get(key) is True for key in required) and
            result.get('mode') == ('xwayland-glx-software' if software else 'xwayland-glx-s30') and
            result.get('frames') == result.get('swapped') == 12 and
            result.get('pixels_checked') == 589824 and result.get('mismatches') == 0 and
            (result.get('gl_major', 0), result.get('gl_minor', 0)) >= (3, 3),
            'Incomplete XWayland desktop GLX result.')
    renderer = result.get('renderer', '')
    cpu = bool(re.search(r'llvmpipe|softpipe|software', renderer, re.I))
    require(cpu if software else bool(re.search(r'\bS30\b', renderer)) and not cpu,
            'Unexpected GLX renderer.')
    require(software or (result.get('dri3_extension') is True and
                         result.get('dri3_node') == '/dev/dri/renderD128'),
            'XWayland DRI3 did not expose the S30 render node.')
    colors = [bytes(c) for c in ((255,0,0,255), (0,255,0,255), (0,0,255,255), (255,255,255,255))]
    expected = b''.join(colors[(x//16 + 3*(y//16) + 11) % 4] for y in range(192) for x in range(256))
    require(Path(pixels).read_bytes() == expected, 'Saved GLX pixels do not match.')


def inspect_server(stage, kwin_pid, display, auth, software=False, report=None):
    candidates = []
    for entry in Path('/proc').iterdir():
        if not entry.name.isdecimal():
            continue
        try:
            status = (entry / 'status').read_text()
            if not re.search(r'^PPid:\s*' + str(kwin_pid) + r'$', status, re.M):
                continue
            if (entry / 'exe').resolve() != Path('/usr/bin/Xwayland'):
                continue
            args = (entry / 'cmdline').read_bytes().decode().strip('\0').split('\0')
            require(len(args) > 1 and args[1] == display and '-auth' in args and
                    args[args.index('-auth') + 1] == auth,
                    'XWayland server display/authentication differs from the private endpoint.')
            require(entry.stat().st_uid == os.geteuid(), 'Unexpected XWayland owner.')
            candidates.append((entry, args))
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            continue
    require(len(candidates) == 1, 'Cannot identify one XWayland child of the private KWin.')
    entry, args = candidates[0]
    state = {'pid': int(entry.name), 'parent_pid': kwin_pid, 'display': display,
             'authenticated': True, 'exe': '/usr/bin/Xwayland'}
    if report is not None:
        report['server'] = state
        (Path(stage) / 'xwayland-result.json').write_text(json.dumps(report, indent=2) + '\n')
    log = (Path(stage) / 'kwin.log').read_text()
    require(SETUP_OK in log and 'MTT validation: Xwayland startup failed' not in log,
            'The private XWayland startup helper did not complete successfully.')
    state['setup_helper_verified'] = True
    if software:
        state['hardware_server_verified'] = False
        return state
    maps = (entry / 'maps').read_text()
    (Path(stage) / 'xwayland-process-maps.log').write_text(maps)
    mapped = {line.split()[-1] for line in maps.splitlines() if line.split()}
    vendor = Path(stage) / 'vendor/usr/lib/x86_64-linux-gnu'
    expected = {str(vendor / name) for name in ('libEGL_mtgpu.so.0.0.0', 'dri/mtgpu_dri.so', 'dri/musa_dri.so')}
    observed = {path for path in mapped if Path(path).name in ('mtgpu_dri.so', 'musa_dri.so') or
                Path(path).name.startswith('libEGL_')}
    require(expected == observed and not any('swrast_dri.so' in path for path in mapped),
            'XWayland did not exclusively use the vendor hardware EGL/DRI path.')
    fds = []
    for fd in (entry / 'fd').iterdir():
        try:
            link = os.readlink(fd)
            if link.startswith('/dev/dri/'):
                fds.append(link)
        except FileNotFoundError:
            pass
    require('/dev/dri/renderD128' in fds, 'XWayland has no S30 render-node descriptor.')
    faults = [line for line in (Path(stage) / 'kwin.log').read_text().splitlines() if FALLBACK.search(line)]
    require(not faults, 'XWayland glamor failure or software fallback; see kwin.log.')
    state.update(hardware_server_verified=True, drm_fds=sorted(set(fds)), vendor_libraries=sorted(expected),
                 glamor_fallback_messages=faults,
                 evidence_scope='Vendor EGL/DRI mappings, S30 node and no fallback; GLX DRI3 query is checked separately.')
    return state


def run(stage, base_env, kwin_pid, display, auth, software=False):
    stage = Path(stage)
    state = {'passed': False, 'phase': 'launch', 'software_control': software}
    try:
        env = client_env(stage, base_env, display, auth, software)
        with (stage / 'x11-client.log').open('w') as stream:
            process = subprocess.run([str(stage / 'desktop/x11-check'), 'software' if software else 's30',
                                      str(stage / 'x11.rgba')], env=env, stdout=stream,
                                     stderr=subprocess.STDOUT, timeout=18)
        state.update(client_exit=process.returncode, phase='server_identity')
        state['server'] = inspect_server(stage, kwin_pid, display, auth, software, report=state)
        require(process.returncode == 0, 'XWayland GLX client failed.')
        result = last_json(stage / 'x11-client.log')
        validate_result(result, stage / 'x11.rgba', software)
        state['client'] = result
        if not software:
            text = (stage / 'x11-client.log').read_text()
            libraries = {line.removeprefix('Graphics library: ') for line in text.splitlines()
                         if line.startswith('Graphics library: ')}
            vendor = stage / 'vendor/usr/lib/x86_64-linux-gnu'
            required = {str(vendor / name) for name in ('libGLX_mtgpu.so.0.0.0', 'dri/mtgpu_dri.so', 'dri/musa_dri.so')}
            observed = {str(Path(path).resolve(strict=True)) for path in libraries
                        if Path(path).name in ('mtgpu_dri.so', 'musa_dri.so') or
                        Path(path).name.startswith('libGLX_')}
            require(required == observed and not any('swrast_dri.so' in path for path in libraries),
                    'GLX client did not select the reviewed vendor libraries.')
            device = os.stat('/dev/dri/renderD128')
            require(stat.S_ISCHR(device.st_mode) and
                    (result.get('dri3_device_major'), result.get('dri3_device_minor')) ==
                    (os.major(device.st_rdev), os.minor(device.st_rdev)),
                    'DRI3 descriptor device identity differs from the S30 node.')
            state['vendor_libraries'] = sorted(required)
        state.update(passed=True, phase='complete')
    except Exception as error:
        state['error'] = str(error)
        raise
    finally:
        (stage / 'xwayland-result.json').write_text(json.dumps(state, indent=2) + '\n')
    return state
