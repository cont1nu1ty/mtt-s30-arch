#!/usr/bin/env python3
"""Build the direct GLX checker; does not connect to a display."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    out = parser.parse_args().output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    source = out / 'x11-check.cpp'
    source.write_bytes(Path(__file__).with_name('x11-check.cpp').read_bytes())
    flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'x11', 'gl', 'xcb', 'xcb-dri3'], text=True))
    command = ['c++', '-std=c++17', '-O2', '-g', '-Wall', '-Wextra', '-Werror',
               '-ffile-prefix-map=' + str(out) + '=/mtt-x11-check', str(source), '-ldl', '-pthread',
               '-o', str(out / 'x11-check'), *flags]
    with (out / 'build.log').open('w') as log:
        subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=60)
    result = {'binary_sha256': sha(out / 'x11-check'), 'source_sha256': sha(source),
              'builder_sha256': sha(Path(__file__)), 'command': command,
              'compiler': subprocess.check_output(['c++', '--version'], text=True)}
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(out / 'x11-check')


if __name__ == '__main__':
    main()
