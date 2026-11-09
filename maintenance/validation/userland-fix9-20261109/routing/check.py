"""Run Mesa's actual loader function and enumerate the DSOs it maps in fresh processes."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess

work = Path(__file__).resolve().parent
project = work.parents[1]
desktop = work / 'desktop'
vendor = project / 'work/egl-gles-dispatch-final-20261106/dependency-stage/vendor/usr/lib/x86_64-linux-gnu'
client = desktop / 'client-dri'
egl = desktop / 'egl/libEGL_mesa.so.0'
primary = 'mtgpu_dri.so'
secondary = 'musa_dri.so'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def symbol(path, name):
    symbols = subprocess.check_output(['nm', '-an', path], text=True).splitlines()
    return next(line.split()[0] for line in symbols if line.split()[1:] == ['t', name])


assert sha(egl) == '6c8de88d01a2a3a7a61a95aa1e3a98b26d37dcc67d916a2302fb41c05f050fd3'
assert sha(client / primary) == '05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23'
assert sha(vendor / 'dri' / primary) == '2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c'
assert sha(client / secondary) == sha(vendor / 'dri' / secondary) == '0c8ddef50a68b20db4fcb1b5e91a5c74075fa0c5527b3a9b45cd93aeaec3532b'

for directory, name in [('only-primary', primary), ('only-secondary', secondary)]:
    subdir = work / directory
    subdir.mkdir(exist_ok=True)
    shutil.copyfile(client / name, subdir / name)

cases = [
    ('repaired', client, [primary, secondary], 1),
    ('stock', vendor / 'dri', [primary, secondary], 1),
    ('missing-secondary', work / 'only-primary', [primary], 1),
    ('missing-primary', work / 'only-secondary', [], 0),
]
result = {}
for label, directory, expected, ext in cases:
    cmd = [str(work / 'route'), str(egl), symbol(egl, 'loader_open_driver')]
    env = {'LC_ALL': 'C', 'PATH': '/usr/bin', 'LIBGL_DRIVERS_PATH': str(directory),
           'LD_LIBRARY_PATH': str(desktop / 'egl') + ':' + str(vendor), 'HOME': str(work)}
    p = subprocess.run(cmd, cwd=work, env=env, text=True, capture_output=True, timeout=10)
    (work / (label + '.log')).write_text(p.stdout + p.stderr)
    assert p.returncode == 0, (label, p.returncode, p.stderr)
    mapped = sorted(Path(s.split('=',1)[1]) for s in p.stdout.splitlines() if s.startswith('mapped='))
    assert mapped == sorted((directory / name).resolve() for name in expected), (label, mapped)
    assert 'extensions=' + str(ext) in p.stdout.splitlines(), (label, p.stdout)
    result[label] = {'dri_paths': [str(f) for f in mapped], 'sha256': [sha(f) for f in mapped],
                     'primary_extensions_returned': bool(ext), 'libgl_drivers_path': str(directory),
                     'uid': os.getuid(), 'ioctl_and_connect_would_kill_process': True}
(work / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
print('Passed:', ', '.join(result))
