"""Bounded Plasma workspace check inside the already isolated KWin session.

This starts the real shell, ActivityManager and KIO daemon, not a login session.
No systemd user environment, autostart directory or existing desktop is used.
"""
import json
import os
from pathlib import Path
import re
import subprocess
import time

from workload_support import require


PACKAGES = {'plasma-workspace': '6.8.2-1', 'plasma-desktop': '6.8.2-1',
            'kactivitymanagerd': '6.8.2-1', 'kio': '6.31.0-1'}
FILES = ('plasma.log', 'plasma-activities.log', 'plasma-kio.log',
         'plasma-before.json', 'plasma-after.json', 'plasma-process-maps.log',
         'plasma-result.json')
SNAPSHOT = '''var ds=desktops(); var ps=panels();
print(JSON.stringify({desktops:ds.map(function(d){return {id:d.id,type:d.type,screen:d.screen};}),
panels:ps.map(function(p){return {id:p.id,type:p.type,screen:p.screen,height:p.height,
widgets:p.widgets().map(function(w){return w.type;})};})}));'''


def validate_environment(stage, env):
    stage = Path(stage).resolve()
    expected = {'HOME': 'desktop-home', 'XDG_CONFIG_HOME': 'desktop-config',
                'XDG_DATA_HOME': 'desktop-data', 'XDG_CACHE_HOME': 'desktop-cache',
                'XDG_STATE_HOME': 'desktop-state', 'XDG_RUNTIME_DIR': 'desktop-runtime'}
    for key, name in expected.items():
        require(env.get(key) == str(stage / name), 'Plasma environment escaped private stage: ' + key)
    require(env.get('WAYLAND_DISPLAY') == 'mtt-s30-test', 'Plasma has the wrong Wayland socket.')
    address = env.get('DBUS_SESSION_BUS_ADDRESS', '')
    require(address.startswith('unix:') and '/run/user/' not in address and
            address == os.environ.get('DBUS_SESSION_BUS_ADDRESS'), 'Plasma private D-Bus missing.')
    require('LD_PRELOAD' not in env, 'Unexpected preload in Plasma environment.')
    if 'DISPLAY' in env or 'XAUTHORITY' in env:
        path = stage / 'private-xwayland.json'
        require(path.is_file() and not path.is_symlink() and path.stat().st_uid == os.geteuid()
                and not path.stat().st_mode & 0o077 and path.stat().st_size < 4096,
                'Private XWayland endpoint record missing or unsafe.')
        endpoint = json.loads(path.read_text())
        require(re.fullmatch(r':1\d\d', endpoint.get('display', '')) and
                endpoint.get('xauthority') == str(stage / 'desktop-runtime/xauthority') and
                env.get('DISPLAY') == endpoint['display'] and env.get('XAUTHORITY') == endpoint['xauthority'],
                'Plasma X11 environment is not the authenticated private endpoint.')


def validate_snapshot(data):
    desktops, panels = data.get('desktops', []), data.get('panels', [])
    require(bool(desktops) and all(d.get('type') == 'org.kde.plasma.folder' and
            isinstance(d.get('screen'), int) and d['screen'] >= 0 for d in desktops),
            'Plasma has no real folder desktop on an output.')
    expected = {'org.kde.plasma.kickoff', 'org.kde.plasma.icontasks',
                'org.kde.plasma.systemtray', 'org.kde.plasma.digitalclock'}
    require(bool(panels) and any(p.get('type') == 'org.kde.panel' and
            isinstance(p.get('screen'), int) and p['screen'] >= 0 and
            isinstance(p.get('height'), (int, float)) and p['height'] > 0 and
            expected.issubset(set(p.get('widgets', []))) for p in panels),
            'Plasma default desktop panel is incomplete.')


def graphics_evidence(text, maps, stage, software=False):
    identities = re.findall(r'^qt\.rhi\.general: OpenGL VENDOR: (.+) RENDERER: (.+) VERSION: (.+)$', text, re.M)
    require(bool(identities), 'Plasma did not create its own OpenGL RHI context.')
    for vendor, renderer, version in identities:
        cpu = bool(re.search(r'llvmpipe|softpipe', renderer, re.I))
        require(cpu if software else bool(re.search(r'\bS30\b', renderer)) and not cpu,
                'Plasma renderer is not the requested device: ' + renderer)
        number = re.match(r'(\d+)\.(\d+)', version)
        require('OpenGL ES' not in version and number and tuple(map(int, number.groups())) >= (3, 3),
                'Plasma did not exercise its desktop OpenGL path.')
    mapped = {line.split()[-1] for line in maps.splitlines() if line.split() and line.split()[-1].startswith('/')}
    private_egl = str(Path(stage) / 'desktop/egl/libEGL_mesa.so.0') in mapped
    observed = {p for p in mapped if Path(p).name in ('mtgpu_dri.so', 'musa_dri.so')}
    expected = {str(Path(stage) / 'desktop/client-dri' / name) for name in ('mtgpu_dri.so', 'musa_dri.so')}
    require(private_egl and (software or observed == expected), 'Plasma loaded unexpected EGL/DRI libraries.')
    layers = re.findall(r'get_layer_surface\(new id zwlr_layer_surface_v1#\d+, wl_surface#(\d+), '
                        r'wl_output#\d+, \d+, "(desktop|dock)"\)', text)
    drawn = {}
    for surface, role in layers:
        attached = re.search(r'wl_surface#' + surface + r'\.attach\(wl_buffer#\d+,', text)
        committed = re.search(r'wl_surface#' + surface + r'\.commit\(', text)
        if attached and committed:
            drawn[role] = surface
    require(set(drawn) == {'desktop', 'dock'}, 'Plasma desktop/panel did not submit rendered buffers.')
    dmabuf_buffers = set(re.findall(r'zwp_linux_buffer_params_v1#\d+\.create_immed\(new id wl_buffer#(\d+),', text))
    gpu_layers = {role: sorted(set(re.findall(r'wl_surface#' + surface +
                  r'\.attach\(wl_buffer#(\d+),', text)) & dmabuf_buffers) for role, surface in drawn.items()}
    require(software or all(gpu_layers.values()), 'Plasma desktop/panel did not submit DMA-BUF buffers.')
    faults = [line for line in text.splitlines() if re.search(
        r'Failed to create RHI|Failed to create OpenGL context|Failed to initialize graphics backend|'
        r'Failed to compile (?:fragment|vertex) shader|Failed to link shader|GL_CONTEXT_LOST|'
        r'QRhiGles2: Failed to|double free|Segmentation fault', line, re.I)]
    require(not faults, 'Plasma graphics fault: ' + repr(faults))
    return {'opengl_contexts': [{'vendor': v, 'renderer': r, 'version': ver} for v, r, ver in identities],
            'private_egl_verified': private_egl, 'private_dri_pair_verified': observed == expected,
            'drawn_layer_surfaces': drawn,
            'dmabuf_buffers_per_layer': gpu_layers,
            'layer_buffer_submissions': {role: len(re.findall(r'wl_surface#' + surface +
                r'\.attach\(wl_buffer#\d+,', text)) for role, surface in drawn.items()},
            'graphics_faults': faults}


def run(stage, client_env, software=False, exercise=None):
    stage = Path(stage).resolve()
    validate_environment(stage, client_env)
    env = dict(client_env, QT_QPA_PLATFORM='wayland', QSG_RHI_BACKEND='opengl', QSG_INFO='1',
               QT_SCALE_FACTOR='1', QT_ENABLE_HIGHDPI_SCALING='0', XDG_CURRENT_DESKTOP='KDE',
               KDE_FULL_SESSION='true', QT_FORCE_STDERR_LOGGING='1',
               QT_LOGGING_RULES='qt.rhi.general=true;qt.scenegraph.general=true')
    state = {'passed': False, 'mode': 'plasma-software' if software else 'plasma-s30',
             'phase': 'startup', 'forced_kill': False, 'full_login_session_tested': False}
    processes = []
    shell = None

    def save():
        (stage / 'plasma-result.json').write_text(json.dumps(state, indent=2) + '\n')

    def dbus(*args):
        return subprocess.check_output(['qdbus6', *args], env=env, text=True,
                                       stderr=subprocess.STDOUT, timeout=3).strip()

    def owner(name):
        owned = dbus('org.freedesktop.DBus', '/org/freedesktop/DBus',
                     'org.freedesktop.DBus.NameHasOwner', name)
        return int(dbus('org.freedesktop.DBus', '/org/freedesktop/DBus',
                        'org.freedesktop.DBus.GetConnectionUnixProcessID', name)) if owned == 'true' else None

    def script(code):
        return dbus('org.kde.plasmashell', '/PlasmaShell', 'org.kde.PlasmaShell.evaluateScript', code)

    def launch(path, log):
        with (stage / log).open('w') as stream:
            process = subprocess.Popen(path, env=env, stdout=stream, stderr=subprocess.STDOUT)
        processes.append((log, process))
        return process

    try:
        # The caller supplies a private daemon with no automatic service dirs.
        activatable = dbus('org.freedesktop.DBus', '/org/freedesktop/DBus',
                           'org.freedesktop.DBus.ListActivatableNames')
        require(not any(name.strip() != 'org.freedesktop.DBus' for name in activatable.splitlines()),
                'Plasma requires a private D-Bus daemon without automatic activation services.')
        require(owner('org.kde.plasmashell') is None and owner('org.kde.ActivityManager') is None,
                'Plasma or activities already owns this bus.')
        activities = launch(['/usr/lib/kactivitymanagerd'], 'plasma-activities.log')
        kio = launch(['/usr/lib/kf6/kiod6'], 'plasma-kio.log')
        shell = launch(['/usr/bin/plasmashell', '--no-respawn'], 'plasma.log')
        state.update(shell_pid=shell.pid, activity_pid=activities.pid, kio_pid=kio.pid)
        save()
        deadline = time.monotonic() + 25
        before = None
        while time.monotonic() < deadline:
            require(all(p.poll() is None for _, p in processes), 'Plasma workspace process exited during startup.')
            if (owner('org.kde.plasmashell') == shell.pid and
                    owner('org.kde.ActivityManager') == activities.pid and owner('org.kde.kiod6') == kio.pid):
                try:
                    before = json.loads(script(SNAPSHOT))
                    (stage / 'plasma-before.json').write_text(json.dumps(before, indent=2) + '\n')
                    validate_snapshot(before)
                    maps = (Path('/proc') / str(shell.pid) / 'maps').read_text()
                    (stage / 'plasma-process-maps.log').write_text(maps)
                    state.update(graphics_evidence((stage / 'plasma.log').read_text(), maps, stage, software))
                    break
                except (RuntimeError, json.JSONDecodeError, subprocess.CalledProcessError) as error:
                    state['last_startup_observation'] = str(error)
                    save()
            time.sleep(0.2)
        else:
            raise RuntimeError('Plasma desktop/panel startup timed out.')
        state['phase'] = 'desktop_ready'
        (stage / 'plasma-before.json').write_text(json.dumps(before, indent=2) + '\n')
        active = dbus('org.kde.ActivityManager', '/ActivityManager/Activities',
                      'org.kde.ActivityManager.Activities.CurrentActivity')
        require(bool(re.fullmatch(r'[0-9a-f-]{36}', active)) and active != '00000000-0000-0000-0000-000000000000',
                'No active private Plasma activity.')
        state['active_activity'] = active
        require((Path('/proc') / str(shell.pid) / 'exe').resolve() == Path('/usr/bin/plasmashell'),
                'Unexpected Plasma executable.')
        maps = (Path('/proc') / str(shell.pid) / 'maps').read_text()
        (stage / 'plasma-process-maps.log').write_text(maps)
        state.update(graphics_evidence((stage / 'plasma.log').read_text(), maps, stage, software))
        initial_dock_frames = state['layer_buffer_submissions']['dock']
        panel = before['panels'][0]
        require(isinstance(panel['id'], int), 'Unexpected panel identity.')
        height = panel['height']
        script(f'var p=panelById({panel["id"]}); p.height={height + 2}; print(p.height);')
        changed = json.loads(script(SNAPSHOT))
        require(any(p['id'] == panel['id'] and p['height'] == height + 2 for p in changed['panels']),
                'Plasma panel did not accept a private layout change.')
        time.sleep(0.3)
        script(f'var p=panelById({panel["id"]}); p.height={height}; print(p.height);')
        time.sleep(0.5)
        after = json.loads(script(SNAPSHOT))
        validate_snapshot(after)
        require(after == before, 'Plasma panel did not restore its initial layout.')
        (stage / 'plasma-after.json').write_text(json.dumps(after, indent=2) + '\n')
        state.update(panel_layout_change_and_restore=True, phase='exercise')
        save()
        if exercise is not None:
            state['exercise'] = exercise()
        require(shell.poll() is None and owner('org.kde.plasmashell') == shell.pid,
                'Plasma exited during the application exercise.')
        maps = (Path('/proc') / str(shell.pid) / 'maps').read_text()
        (stage / 'plasma-process-maps.log').write_text(maps)
        state.update(graphics_evidence((stage / 'plasma.log').read_text(), maps, stage, software))
        require(state['layer_buffer_submissions']['dock'] > initial_dock_frames,
                'Plasma panel did not redraw after its layout change.')
        state['checks_passed'] = True
    except Exception as error:
        state['error'] = str(error)
    finally:
        state['exit_codes'] = {}
        for name, process in reversed(processes):
            requested = process.poll() is None
            if requested:
                process.terminate()
            try:
                code = process.wait(timeout=4)
            except subprocess.TimeoutExpired:
                state['forced_kill'] = True
                process.kill()
                code = process.wait(timeout=2)
            state['exit_codes'][name] = {'code': code, 'termination_requested': requested}
        if state.get('checks_passed'):
            try:
                state.update(graphics_evidence((stage / 'plasma.log').read_text(), maps, stage, software))
            except Exception as error:
                state['error'] = str(error)
        state['passed'] = (state.get('checks_passed', False) and not state['forced_kill'] and
                           'error' not in state and
                           all(item['termination_requested'] and item['code'] in (0, 15, -15)
                               for item in state['exit_codes'].values()) and
                           state['exit_codes'].get('plasma.log', {}).get('code') in (0, 15))
        state['phase'] = 'complete' if state['passed'] else 'failed'
        save()
    require(state['passed'], state.get('error', 'Plasma workspace did not exit cleanly.'))
    return state
