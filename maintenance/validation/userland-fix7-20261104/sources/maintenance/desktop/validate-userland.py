#!/usr/bin/env python3
"""Virtual KWin plus the packaged compatibility EGL and an explicit CPU driver.

The extra Ubuntu software driver/LLVM libraries are test fixtures only. They
are never staged in the privileged hardware bundle or accepted as S30 results.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import shlex
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'maintenance/recovery'))
import desktop_support as desktop
from workload_support import last_json


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--bundle', type=Path, required=True)
    parser.add_argument('--stage', type=Path, required=True)
    parser.add_argument('--software-root', type=Path, required=True)
    parser.add_argument('--inner', action='store_true')
    args = parser.parse_args()
    stage, software = args.stage.resolve(), args.software_root.resolve()
    if not args.inner:
        assert not Path('/sys/module/mtgpu').exists(), 'Protocol controls require the GPU driver to be unloaded.'
        stage.mkdir(mode=0o700)
        desktop.stage_bundle(args.bundle.resolve(), stage / 'desktop')
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'egl', 'wayland-client'], text=True))
        subprocess.run(['cc', '-Wall', '-Wextra', '-Werror', str(ROOT / 'maintenance/desktop/egl-init-probe.c'),
                        '-o', str(stage / 'egl-init-probe'), *flags], check=True)
        env = desktop.isolated_env(stage, {}, software=True)
        with (stage / 'validation.log').open('w') as stream:
            run = subprocess.run(['dbus-run-session', '--', sys.executable, __file__,
                                  '--bundle', str(args.bundle.resolve()), '--stage', str(stage),
                                  '--software-root', str(software), '--inner'], env=env,
                                 stdout=stream, stderr=subprocess.STDOUT, timeout=75)
        print('Virtual compatibility session exit:', run.returncode)
        if (stage / 'desktop-session-result.json').exists():
            print((stage / 'desktop-session-result.json').read_text())
        if run.returncode:
            raise RuntimeError('Virtual compatibility validation failed; see ' + str(stage))
        result = last_json(stage / 'wayland-client.log')
        desktop.validate_egl(result, stage / 'wayland.rgba', window=True, software=True)
        assert 'Graphics library: ' + str(stage / 'desktop/egl/libEGL_mesa.so.0') in (stage / 'wayland-client.log').read_text()
        print('Independent final pixels and private EGL binding verified.')
        return

    assert os.geteuid() != 0, 'Software validation must not run as root.'
    original = desktop.wayland_client_env

    def cpu_client(stage, env, software=False):
        result = original(stage, env, software=True)
        result.update(LD_LIBRARY_PATH=str(Path(stage) / 'desktop/egl') + ':' +
                      str(args.software_root.resolve() / 'usr/lib/x86_64-linux-gnu') + ':' +
                      str(args.software_root.resolve() / 'lib/x86_64-linux-gnu'),
                      LIBGL_DRIVERS_PATH=str(args.software_root.resolve() / 'usr/lib/x86_64-linux-gnu/dri'),
                      __EGL_VENDOR_LIBRARY_FILENAMES=str(Path(stage) / 'desktop/egl/50_mesa.json'),
                      LIBGL_ALWAYS_SOFTWARE='1', GALLIUM_DRIVER='softpipe')
        # The virtual compositor has no real S30 render node. Both hardware
        # initialization attempts must fail; only protocol progression differs.
        vendor = ROOT / 'official/driver-3.1.0/usr/lib/x86_64-linux-gnu'
        for name in ('vendor', 'compatible'):
            probe_env = dict(result, LIBGL_DRIVERS_PATH=str(vendor / 'dri'))
            for key in ('LIBGL_ALWAYS_SOFTWARE', 'MESA_LOADER_DRIVER_OVERRIDE', 'GALLIUM_DRIVER'):
                probe_env.pop(key, None)
            probe_env['LD_LIBRARY_PATH'] = (str(Path(stage) / 'desktop/egl') + ':' if name == 'compatible' else '') + str(vendor)
            if name == 'vendor':
                probe_env['__EGL_VENDOR_LIBRARY_FILENAMES'] = str(ROOT / 'official/driver-3.1.0/usr/share/glvnd/egl_vendor.d/00_mtgpu.json')
            probe = subprocess.run([str(Path(stage) / 'egl-init-probe')], env=probe_env,
                                   capture_output=True, text=True, timeout=5)
            text = probe.stdout + probe.stderr
            (Path(stage) / (name + '-protocol.log')).write_text(text)
            assert probe.returncode == 2, 'Hardware initialization unexpectedly succeeded in the software control.'
            if name == 'compatible':
                assert 'get_default_feedback(' in text, 'Compatibility EGL did not request modern device feedback.'
            else:
                assert 'get_default_feedback(' not in text, 'Vendor protocol baseline changed.'
        return result

    desktop.wayland_client_env = cpu_client
    sys.exit(desktop.session(stage, '-', software=True))


if __name__ == '__main__':
    main()
