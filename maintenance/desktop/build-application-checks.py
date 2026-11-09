#!/usr/bin/env python3
"""Reuse the v10 libraries and reproducibly build lifecycle and Qt Quick checks."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
BASE = ROOT / 'builds/desktop-userland-fix9-20261109'
BASE_SHA = '747d5896a604dd03bbae5b136082a635ad26bc7d0aa7d10275a3a487e9450304'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    out = parser.parse_args().output.absolute()
    if out.exists():
        raise ValueError('Output must be new.')
    if digest(BASE / 'manifest.json') != BASE_SHA:
        raise ValueError('The verified v10 base manifest changed.')
    base = json.loads((BASE / 'manifest.json').read_text())
    with tempfile.TemporaryDirectory(dir=out.parent) as temporary:
        tmp = Path(temporary)
        bundle = tmp / 'bundle'
        for name, meta in base['files'].items():
            path = BASE / name
            if digest(path) != meta['sha256'] or path.stat().st_size != meta['size']:
                raise ValueError('The v10 payload changed: ' + name)
            if name == 'egl-check':
                continue
            target = bundle / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
        sources = {}
        for name in ('egl-check.c', 'qt-check.cpp'):
            shutil.copyfile(HERE / name, tmp / name)
            sources[name] = digest(tmp / name)
        protocols = {}
        for name in ('xdg-shell', 'presentation-time'):
            path = Path('/usr/share/qt6/wayland/protocols') / name / (name + '.xml')
            protocols[str(path)] = digest(path)
            for mode, suffix in (('client-header', '-client-protocol.h'), ('private-code', '-protocol.c')):
                subprocess.run(['wayland-scanner', mode, str(path), str(tmp / (name + suffix))], check=True)
        commands = []
        common = ['-O2', '-g', '-Wall', '-Wextra', '-Werror', '-ffile-prefix-map=' + str(tmp) + '=/mtt-s30-checks']
        specs = [('egl-check', 'cc', '-std=c11', ['egl-check.c', 'xdg-shell-protocol.c', 'presentation-time-protocol.c'],
                  ['egl', 'glesv2', 'gbm', 'libdrm', 'wayland-client', 'wayland-egl'], []),
                 ('qt-check', 'c++', '-std=c++17', ['qt-check.cpp'], ['Qt6Core', 'Qt6Gui', 'Qt6Quick'], ['-fPIC', '-ldl'])]
        for name, compiler, standard, files, modules, extra in specs:
            flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', *modules], text=True))
            command = [compiler, standard, *common, '-I' + str(tmp), *(str(tmp / file) for file in files),
                       *extra, '-o', str(bundle / name), *flags]
            subprocess.run(command, check=True, timeout=60)
            commands.append([arg.replace(str(tmp), '/mtt-s30-checks') for arg in command])
        metadata = {'profile': 'kwin-wayland-v11', 'base_manifest_sha256': BASE_SHA,
                    'builder_sha256': digest(Path(__file__)), 'source_sha256': sources,
                    'protocol_sha256': protocols, 'commands': commands,
                    'compiler': subprocess.check_output(['cc', '--version'], text=True),
                    'qt_versions': subprocess.check_output(['pkg-config', '--modversion', 'Qt6Core', 'Qt6Gui', 'Qt6Quick'], text=True).splitlines(),
                    'files': {str(p.relative_to(bundle)): {'sha256': digest(p), 'size': p.stat().st_size}
                              for p in sorted(bundle.rglob('*')) if p.is_file()},
                    'hardware_tested': False}
        (bundle / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
        out.mkdir()
        try:
            bundle.replace(out)
        except OSError:
            out.rmdir()
            raise
    print('Bundle:', out)
    print('Manifest SHA256:', digest(out / 'manifest.json'))


if __name__ == '__main__':
    main()
