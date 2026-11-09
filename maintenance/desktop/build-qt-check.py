#!/usr/bin/env python3
"""Build the Qt Quick Wayland checker into a new project directory."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess

SOURCE = Path(__file__).with_name('qt-check.cpp')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    out = parser.parse_args().output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    source = out / 'qt-check.cpp'
    source.write_bytes(SOURCE.read_bytes())
    modules = ['Qt6Core', 'Qt6Gui', 'Qt6Quick']
    flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', *modules], text=True))
    command = ['c++', '-std=c++17', '-O2', '-g', '-fPIC', '-Wall', '-Wextra', '-Werror',
               str(source), '-ldl', '-o', str(out / 'qt-check'), *flags]
    with (out / 'build.log').open('w') as log:
        subprocess.run(command, check=True, stdout=log, stderr=subprocess.STDOUT)
    manifest = {'source_sha256': digest(source), 'binary_sha256': digest(out / 'qt-check'),
                'builder_sha256': digest(Path(__file__)), 'command': command,
                'compiler': subprocess.check_output(['c++', '--version'], text=True),
                'qt_versions': subprocess.check_output(['pkg-config', '--modversion', *modules], text=True).splitlines()}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(out / 'qt-check')


if __name__ == '__main__':
    main()
