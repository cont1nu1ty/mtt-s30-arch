"""Probe the vendor's Wayland negotiation against an isolated software KWin.

No driver is loaded and no physical output is used. Failure is expected; this
experiment can reveal protocol negotiation, not prove hardware compatibility.
"""
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'maintenance/recovery'))
import desktop_support as d

if len(sys.argv) == 1:
    stage = ROOT / 'work/wayland-vendor-negotiation-20261031'
    stage.mkdir()
    env = d.isolated_env(stage, {}, software=True)
    env['QT_FORCE_STDERR_LOGGING'] = '1'
    subprocess.run(['dbus-run-session', '--', sys.executable, __file__, str(stage)],
                   env=env, timeout=45, check=True)
else:
    stage = Path(sys.argv[1])
    proc = None
    try:
        with (stage / 'kwin.log').open('w') as log:
            proc = subprocess.Popen(['kwin_wayland', '--virtual', '--width', '800', '--height', '600',
                                     '--socket', 'mtt-negotiation', '--no-lockscreen',
                                     '--no-global-shortcuts', '--no-kactivities'],
                                    stdout=log, stderr=subprocess.STDOUT)
        for _ in range(100):
            if proc.poll() is not None:
                raise RuntimeError('Software compositor exited')
            if (stage / 'desktop-runtime/mtt-negotiation').exists():
                break
            time.sleep(0.1)
        else:
            raise RuntimeError('Software compositor startup timed out')
        time.sleep(2)
        vendor = ROOT / 'official/driver-3.1.0/usr/lib/x86_64-linux-gnu'
        env = dict(os.environ, WAYLAND_DISPLAY='mtt-negotiation', WAYLAND_DEBUG='client',
                   LD_LIBRARY_PATH=str(vendor), LIBGL_DRIVERS_PATH=str(vendor / 'dri'),
                   GBM_BACKENDS_PATH=str(vendor / 'gbm'), GBM_BACKEND='mtgpu',
                   __EGL_VENDOR_LIBRARY_FILENAMES=str(ROOT / 'official/driver-3.1.0/usr/share/glvnd/egl_vendor.d/00_mtgpu.json'))
        for key in ('LIBGL_ALWAYS_SOFTWARE', 'MESA_LOADER_DRIVER_OVERRIDE'):
            env.pop(key, None)
        with (stage / 'vendor-client.log').open('w') as log:
            run = subprocess.run([str(ROOT / 'builds/desktop-20261031/egl-check'), 'wayland', '-',
                                  str(stage / 'unexpected.rgba')],
                                 stdout=log, stderr=subprocess.STDOUT, env=env, timeout=10)
        print('Vendor client exit:', run.returncode)
        print('Trace:', stage / 'vendor-client.log')
    finally:
        if proc is not None and proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=8)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait(timeout=3)
