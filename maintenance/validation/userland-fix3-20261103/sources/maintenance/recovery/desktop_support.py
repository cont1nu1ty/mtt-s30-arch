"""Private KWin session and strict EGL/Wayland acceptance checks.

Hardware mode is invoked only by the armed recovery probe. The explicit software
mode exercises a virtual compositor without connecting to the user's desktop.
"""
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import signal
import stat
import subprocess
import sys
import time
from workload_support import digest, require, last_json

PROFILE = 'kwin-wayland-v4'
MANIFEST_SHA = '2c1805f9c9e0305fd7126a15cf156cfcbdc84745b4bba6597ef55aea64ee4c79'
BUNDLE_DIRECTORY = 'desktop-userland-fix3-v3-20261103'
WIDTH, HEIGHT = 256, 192
USERLAND_FILES = {'egl-check', 'kwin/kwin_wayland', 'kwin/libkwin.so.6',
                  'egl/libEGL_mesa.so.0', 'egl/libglapi.so.0', 'egl/50_mesa.json'}
BUILD_MARKER = 'MTT S30 isolated validation build: userland-fix1 (KWin 6.8.2)'
EGL_LOOKUP_MARKER = 'MTT compatibility: Wayland DRI_IMAGE_LOOKUP v1'
EGL_SCREEN_MARKER = 'MTT compatibility: opaque DRI screen callbacks'
EGL_CONTEXT_MARKER = 'MTT compatibility: public DRI context callbacks'
# Re-reviewed after the 2026-11-03 upgrade with the private software session.
REVIEWED_DESKTOP_PACKAGES = {'kwin': '6.8.2-1', 'mesa': '1:26.2.6-1',
                            'qt6-base': '6.12.0-3', 'qt6-declarative': '6.12.0-4',
                            'kdecoration': '6.8.2-1'}


def verify_host():
    for name in ('kwin_wayland', 'qdbus6', 'dbus-run-session'):
        require(shutil.which(name, path='/usr/bin:/usr/sbin'), 'Missing desktop program: ' + name)
    versions = subprocess.check_output(['pacman', '-Q', *REVIEWED_DESKTOP_PACKAGES], text=True, timeout=5)
    installed = dict(line.split(maxsplit=1) for line in versions.strip().splitlines())
    require(installed == REVIEWED_DESKTOP_PACKAGES,
            'Desktop packages changed; review before testing. Expected ' +
            json.dumps(REVIEWED_DESKTOP_PACKAGES, sort_keys=True) + '; found ' +
            json.dumps(installed, sort_keys=True))


def verify_bundle(directory):
    directory = Path(directory)
    manifest = directory / 'manifest.json'
    require(stat.S_ISREG(manifest.lstat().st_mode) and manifest.stat().st_size < 65536,
            'Invalid desktop manifest file.')
    require(digest(manifest) == MANIFEST_SHA, 'Desktop manifest checksum changed.')
    data = json.loads(manifest.read_text())
    require(data['profile'] == PROFILE and set(data['files']) == USERLAND_FILES, 'Unexpected desktop bundle.')
    for name in ('kwin', 'egl'):
        require(stat.S_ISDIR((directory / name).lstat().st_mode), 'Invalid desktop library directory.')
    for name, metadata in data['files'].items():
        path = directory / name
        info = path.lstat()
        require(stat.S_ISREG(info.st_mode) and 0 < info.st_size <= 64 * 1024 * 1024,
                'Invalid desktop bundle file: ' + name)
        require(info.st_size == metadata['size'] and digest(path) == metadata['sha256'],
                'Desktop bundle checksum changed: ' + name)


def stage_bundle(source, destination):
    verify_bundle(source)
    destination = Path(destination)
    destination.mkdir(mode=0o700)
    for name in ('kwin', 'egl'):
        (destination / name).mkdir(mode=0o700)
    for name in USERLAND_FILES | {'manifest.json'}:
        target = destination / name
        shutil.copyfile(Path(source) / name, target)
        target.chmod(0o500 if name in ('egl-check', 'kwin/kwin_wayland') else 0o400)
    verify_bundle(destination)


def verify_runtime_dependencies(stage):
    stage = Path(stage)
    search = ':'.join(str(stage / p) for p in ('desktop/kwin', 'desktop/egl', 'vendor/usr/lib/x86_64-linux-gnu'))
    env = {'PATH': '/usr/bin:/usr/sbin', 'LC_ALL': 'C', 'LD_LIBRARY_PATH': search}
    for name in ('kwin/kwin_wayland', 'kwin/libkwin.so.6', 'egl/libEGL_mesa.so.0', 'egl-check'):
        result = subprocess.check_output(['ldd', str(stage / 'desktop' / name)], env=env,
                                         text=True, stderr=subprocess.STDOUT, timeout=10)
        require('not found' not in result, 'Missing private desktop dependency: ' + name + '\n' + result)


def renderer_is_hardware(text):
    return bool(re.search(r'\bS30\b', text, re.I)) and not re.search(r'llvmpipe|softpipe|software', text, re.I)


def compositor_faults(text):
    return [line for line in text.splitlines() if re.search(
        r'atomic commit failed|pageflip timed out|modeset failed|'
        r'could not initialize (?:egl|rendering context)|drmPrimeFDToHandle failed|'
        r'failed to compile (?:fragment|vertex) shader|failed to link shader|'
        r'failed to load (?:downsampling|upsampling|noise|onscreen) pass shader|'
        r'Error creating EGLImageKHR|MTT validation: dma-buf import failed|'
        r'EGL_BAD_(?:ALLOC|CONTEXT|SURFACE|MATCH)|GL_(?:OUT_OF_MEMORY|CONTEXT_LOST)', line, re.I)]


def verify_pixels(path, final_frame):
    colors = [bytes((255, 0, 0, 255)), bytes((0, 255, 0, 255)),
              bytes((0, 0, 255, 255)), bytes((255, 255, 255, 255))]
    expected = b''.join(colors[(x // 16 + 3 * (y // 16) + final_frame) % 4]
                        for y in range(HEIGHT) for x in range(WIDTH))
    require(Path(path).read_bytes() == expected, 'Saved GLES pixels differ from expected pattern.')


def validate_egl(result, pixels, window=False, software=False):
    frames = 60 if window else 8
    mode = ('wayland-' if window else ('surfaceless-' if software else 'gbm-')) + ('software' if software else 's30')
    require(result.get('passed') is True and result.get('mode') == mode and
            result.get('frames') == frames and result.get('pixels_checked') == frames * WIDTH * HEIGHT and
            result.get('mismatches') == 0 and result.get('discarded') == 0,
            'Incomplete or wrong-mode GLES result.')
    renderer = result.get('renderer', '')
    require(bool(re.search(r'llvmpipe|softpipe', renderer, re.I)) if software else renderer_is_hardware(renderer),
            'Unexpected GLES renderer.')
    require(result.get('presented') == (frames if window else 0), 'Missing presentation feedback.')
    if window and not software:
        require(result.get('egl_vendor') == 'Mesa Project', 'Wayland client did not use the compatibility EGL loader.')
        require(result.get('hardware_presentations') == frames and
                result.get('presentation_flags_all', 0) & 6 == 6, 'Missing hardware presentation flags.')
    verify_pixels(pixels, frames - 1)


def validate_support(text, software=False):
    require('Compositing is active' in text and 'Compositing Type: OpenGL ES' in text and
            'OpenGL platform interface: EGL' in text, 'KWin is not using EGL/GLES compositing.')
    match = re.search(r'^OpenGL renderer string: (.+)$', text, re.M)
    require(match is not None, 'KWin renderer is missing.')
    renderer = match[1].strip()
    if software:
        require(bool(re.search(r'llvmpipe|softpipe', renderer, re.I)), 'Harness did not use software rendering.')
        require(re.search(r'^Name: KWin::VirtualBackend\s*$', text, re.M), 'Harness is not a virtual compositor.')
    else:
        require(renderer_is_hardware(renderer), 'KWin did not select the S30 hardware renderer.')
        require(re.search(r'^Name: DRM\s*$', text, re.M), 'KWin is not using the real DRM backend.')
        screens = text.split('\nScreen ')[1:]
        require(any(re.search(r'^Name: (HDMI|DP)[^\n]*\nEnabled: 1\nGeometry: .*?[1-9]\d*x[1-9]\d*\n',
                              screen, re.M) for screen in screens), 'No enabled physical display reported by KWin.')
    return renderer


def isolated_env(stage, base, card=None, software=False):
    stage = Path(stage)
    # Deliberately construct a clean environment; never carry the user's session
    # bus, runtime directory, Qt overrides, systemd session id, or KWin settings.
    env = {'PATH': '/usr/bin:/usr/sbin', 'LC_ALL': 'C.UTF-8', 'LANG': 'C.UTF-8',
           'KWIN_DRM_NO_DIRECT_SCANOUT': '1',
           # Preserve GPU dma-buf import. Use KWin's ordinary texture upload
           # for wl_shm buffers instead of wrapping them with /dev/udmabuf.
           'KWIN_DISABLE_UDMABUF_IMPORT': '1',
           # Qt otherwise sends graphics failures to journald, bypassing
           # kwin.log and the live failure checks in this isolated session.
           'QT_FORCE_STDERR_LOGGING': '1',
           'LD_LIBRARY_PATH': str(stage / 'desktop/kwin')}
    for key, subdir in [('HOME', 'desktop-home'), ('XDG_CONFIG_HOME', 'desktop-config'),
                        ('XDG_DATA_HOME', 'desktop-data'), ('XDG_CACHE_HOME', 'desktop-cache'),
                        ('XDG_STATE_HOME', 'desktop-state'), ('XDG_RUNTIME_DIR', 'desktop-runtime')]:
        path = stage / subdir
        path.mkdir(mode=0o700, exist_ok=False)
        env[key] = str(path)
    if software:
        env.update(LIBGL_ALWAYS_SOFTWARE='1', MESA_LOADER_DRIVER_OVERRIDE='swrast',
                   __EGL_VENDOR_LIBRARY_FILENAMES='/usr/share/glvnd/egl_vendor.d/50_mesa.json')
    else:
        vendor = stage / 'vendor/usr/lib/x86_64-linux-gnu'
        env.update(LD_LIBRARY_PATH=str(stage / 'desktop/kwin') + ':' + str(vendor), LIBGL_DRIVERS_PATH=str(vendor / 'dri'),
                   GBM_BACKENDS_PATH=str(vendor / 'gbm'), GBM_BACKEND='mtgpu',
                   __EGL_VENDOR_LIBRARY_FILENAMES=str(stage / 'vendor/usr/share/glvnd/egl_vendor.d/00_mtgpu.json'),
                   KWIN_DRM_DEVICES=card)
    return env


def wayland_client_env(stage, base, software=False):
    env = dict(base, WAYLAND_DISPLAY='mtt-s30-test', WAYLAND_DEBUG='client', EGL_LOG_LEVEL='debug')
    if not software:
        stage = Path(stage)
        vendor = stage / 'vendor/usr/lib/x86_64-linux-gnu'
        # The compositor/GBM use the proven vendor EGL. Only the native
        # Wayland client uses the matching Ubuntu Mesa EGL protocol loader.
        env['LD_LIBRARY_PATH'] = str(stage / 'desktop/egl') + ':' + str(vendor)
        env['__EGL_VENDOR_LIBRARY_FILENAMES'] = str(stage / 'desktop/egl/50_mesa.json')
        env.pop('GBM_BACKEND', None)
        env.pop('GBM_BACKENDS_PATH', None)
    return env


def run_desktop(stage, render, card, env, command, check_kernel):
    stage = Path(stage)
    verify_bundle(stage / 'desktop')
    require(Path(card).parent == Path('/dev/dri') and Path(card).name.startswith('card'), 'Invalid KMS node.')
    clean = isolated_env(stage, env, card)
    require(command('egl-gbm', [str(stage / 'desktop/egl-check'), 'gbm', render,
                               str(stage / 'egl-gbm.rgba')], 20, clean) == 0, 'EGL/GBM drawing failed.')
    egl = last_json(stage / 'egl-gbm.log')
    validate_egl(egl, stage / 'egl-gbm.rgba')
    check_kernel()
    require(command('kwin-session', ['dbus-run-session', '--', '/usr/bin/python3',
                                    str(stage / 'desktop_support.py'), 'session', str(stage), card],
                    75, clean) == 0, 'Isolated KWin/Wayland session failed.')
    session = json.loads((stage / 'desktop-session-result.json').read_text())
    require(session.get('passed') is True and session.get('mode') == 'drm-s30' and
            session.get('kwin_exit') in (0, 15) and session.get('termination_requested') is True and
            session.get('forced_kill') is False,
            'KWin session did not finish cleanly on S30.')
    validate_support((stage / 'kwin-support-before.log').read_text())
    validate_support((stage / 'kwin-support-after.log').read_text())
    window = last_json(stage / 'wayland-client.log')
    validate_egl(window, stage / 'wayland.rgba', window=True)
    check_kernel()
    result = {'passed': True, 'profile': PROFILE, 'egl_gbm': egl, 'wayland_client': window,
              'kwin': session, 'full_plasma_tested': False, 'xwayland_tested': False,
              'scanout_pixels_captured': False}
    (stage / 'desktop-result.json').write_text(json.dumps(result, indent=2) + '\n')
    return result


def check_session_kernel(stage, software):
    if software:
        return
    spec = importlib.util.spec_from_file_location('mtt_kernel_check', stage / 'test-once.py')
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    baseline = (stage / 'kernel-before.log').read_text().splitlines()
    text = subprocess.check_output(['dmesg', '--time-format=raw'], text=True, timeout=5)
    (stage / 'kwin-kernel-check.log').write_text(text)
    lines = text.splitlines()
    require(bool(baseline) and baseline[-1] in lines, 'Kernel boundary lost during KWin session.')
    faults = runner.kernel_faults('\n'.join(lines[lines.index(baseline[-1]) + 1:]))
    require(not faults, 'Kernel fault during KWin session: ' + repr(faults))


def session(stage, card, software=False):
    stage = Path(stage).resolve()
    verify_bundle(stage / 'desktop')
    require(software or os.geteuid() == 0, 'Hardware session must run from the armed root probe.')
    require(os.environ.get('XDG_RUNTIME_DIR') == str(stage / 'desktop-runtime'), 'Wrong session runtime directory.')
    require(os.environ.get('DBUS_SESSION_BUS_ADDRESS'), 'Private session bus missing.')
    state = {'passed': False, 'mode': 'virtual-software' if software else 'drm-s30',
             'kwin_started': False, 'forced_kill': False}
    proc = None

    def save():
        (stage / 'desktop-session-result.json').write_text(json.dumps(state, indent=2) + '\n')

    def support(name):
        text = subprocess.check_output(['qdbus6', 'org.kde.KWin', '/KWin',
                                       'org.kde.KWin.supportInformation'], text=True, stderr=subprocess.STDOUT, timeout=4)
        (stage / name).write_text(text)
        return text

    try:
        if not software:
            require(Path('/sys/module/mtgpu').exists() and
                    Path('/sys/class/watchdog/watchdog0/state').read_text().strip() == 'active',
                    'Driver or armed watchdog missing.')
            require(os.environ.get('KWIN_DRM_DEVICES') == card, 'Wrong KWin DRM device.')
        args = [str(stage / 'desktop/kwin/kwin_wayland'), '--virtual' if software else '--drm', '--socket', 'mtt-s30-test',
                '--no-lockscreen', '--no-global-shortcuts', '--no-kactivities']
        if software:
            args += ['--width', '800', '--height', '600']
        with (stage / 'kwin.log').open('w') as log:
            proc = subprocess.Popen(args, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        state.update(kwin_started=True, kwin_pid=proc.pid);save()
        deadline = time.monotonic() + 20
        while True:
            require(proc.poll() is None, 'KWin exited during startup.')
            require(time.monotonic() < deadline, 'KWin startup timed out.')
            if (stage / 'desktop-runtime/mtt-s30-test').exists():
                try:
                    # Query only an already-owned name; do not ask D-Bus to
                    # auto-activate another compositor while startup is pending.
                    owned = subprocess.check_output(['qdbus6', 'org.freedesktop.DBus', '/org/freedesktop/DBus',
                               'org.freedesktop.DBus.NameHasOwner', 'org.kde.KWin'], text=True, timeout=4).strip()
                    if owned == 'true':
                        info = support('kwin-support-before.log')
                        if 'Compositing is active' in info:
                            break
                except subprocess.CalledProcessError:
                    pass
            time.sleep(0.2)
        owner = int(subprocess.check_output(['qdbus6', 'org.freedesktop.DBus', '/org/freedesktop/DBus',
                    'org.freedesktop.DBus.GetConnectionUnixProcessID', 'org.kde.KWin'], text=True, timeout=4))
        require(owner == proc.pid, 'KWin D-Bus owner is not the isolated process.')
        require(BUILD_MARKER in (stage / 'kwin.log').read_text(), 'Unpatched KWin process detected.')
        if not software:
            require((Path('/proc') / str(proc.pid) / 'exe').resolve() == stage / 'desktop/kwin/kwin_wayland',
                    'KWin executable is outside the private bundle.')
            maps = (Path('/proc') / str(proc.pid) / 'maps').read_text()
            require(str(stage / 'desktop/kwin/libkwin.so.6') in maps,
                    'KWin did not load the private patched library.')
            state['private_kwin_library_verified'] = True
        state['renderer'] = validate_support(info, software)
        state['drm_fds'] = []
        # KWin disables dumpability. The unprivileged software harness cannot
        # inspect its fd table; the root hardware run must prove this binding.
        fds = [] if software else (Path('/proc') / str(proc.pid) / 'fd').iterdir()
        for fd in fds:
            try:
                target = os.readlink(fd)
                if target.startswith('/dev/dri/'):
                    state['drm_fds'].append(target)
            except FileNotFoundError:
                pass
        require(software or card in state['drm_fds'], 'KWin did not open the S30 KMS device.')
        check_session_kernel(stage, software)
        require(not compositor_faults((stage / 'kwin.log').read_text()), 'KWin startup graphics error; see kwin.log.')
        save()
        client_env = wayland_client_env(stage, os.environ, software)
        with (stage / 'wayland-client.log').open('w') as log:
            run = subprocess.run([str(stage / 'desktop/egl-check'),
                                  'software-wayland' if software else 'wayland', '-', str(stage / 'wayland.rgba')],
                                 stdout=log, stderr=subprocess.STDOUT, env=client_env, timeout=20)
        state['client_exit'] = run.returncode
        require(run.returncode == 0, 'Wayland GLES client failed.')
        if not software:
            client_log = (stage / 'wayland-client.log').read_text()
            require('Graphics library: ' + str(stage / 'desktop/egl/libEGL_mesa.so.0') in client_log,
                    'Client did not load the private compatibility EGL.')
            require(EGL_LOOKUP_MARKER in client_log, 'Client did not select the mtgpu lookup-v1 adapter.')
            require(EGL_SCREEN_MARKER in client_log and EGL_CONTEXT_MARKER in client_log,
                    'Client did not select the mtgpu opaque-screen/context adapters.')
            state['private_client_egl_verified'] = True
            state['mtgpu_lookup_v1_selected'] = True
            state['mtgpu_public_screen_and_context_selected'] = True
        validate_egl(last_json(stage / 'wayland-client.log'), stage / 'wayland.rgba', window=True, software=software)
        check_session_kernel(stage, software)
        require(not compositor_faults((stage / 'kwin.log').read_text()), 'KWin rendering error; see kwin.log.')
        validate_support(support('kwin-support-after.log'), software)
        # Keep the last presented window's destruction/compositor cleanup bounded.
        time.sleep(2)
        require(proc.poll() is None, 'KWin exited unexpectedly after the client.')
        state['checks_passed'] = True
    except Exception as e:
        state['error'] = str(e)
    finally:
        if proc is not None:
            if proc.poll() is None:
                # KWin's KSignalHandler passes SIGTERM to QCoreApplication::exit;
                # controlled cleanup returns positive 15, not subprocess -15.
                state['termination_requested'] = True
                proc.terminate()
            try:
                state['kwin_exit'] = proc.wait(timeout=8)
            except subprocess.TimeoutExpired:
                state['forced_kill'] = True
                os.killpg(proc.pid, signal.SIGKILL)
                try:
                    state['kwin_exit'] = proc.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    state['error'] = 'KWin cannot be reaped; recovery supervisor must reboot.'
        state['compositor_faults'] = compositor_faults((stage / 'kwin.log').read_text()) if (stage / 'kwin.log').exists() else []
        state['passed'] = (state.get('checks_passed', False) and state.get('kwin_exit') in (0, 15) and
                           state.get('termination_requested', False) and not state['forced_kill'] and
                           not state['compositor_faults'] and 'error' not in state)
        save()
    return 0 if state['passed'] else 1


if __name__ == '__main__':
    require(len(sys.argv) == 4 and sys.argv[1] in ('session', 'software-session'), 'Unexpected session command.')
    sys.exit(session(Path(sys.argv[2]), sys.argv[3], software=sys.argv[1] == 'software-session'))
