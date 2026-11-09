#!/usr/bin/env python3
"""Build only; no compositor or hardware device is opened."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    out = parser.parse_args().output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    protocols = {}
    for name in ('xdg-shell', 'presentation-time'):
        source = Path('/usr/share/qt6/wayland/protocols') / name / (name + '.xml')
        protocols[str(source)] = hashlib.sha256(source.read_bytes()).hexdigest()
        subprocess.run(['wayland-scanner', 'client-header', str(source),
                        str(out / (name + '-client-protocol.h'))], check=True)
        subprocess.run(['wayland-scanner', 'private-code', str(source),
                        str(out / (name + '-protocol.c'))], check=True)
    flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs',
                        'egl', 'glesv2', 'gbm', 'libdrm', 'wayland-client', 'wayland-egl'], text=True))
    subprocess.run(['cc', '-std=c11', '-O2', '-g', '-Wall', '-Wextra', '-Werror',
                    '-I' + str(out), str(HERE / 'egl-check.c'),
                    str(out / 'xdg-shell-protocol.c'), str(out / 'presentation-time-protocol.c'),
                    '-o', str(out / 'egl-check'), *flags], check=True, timeout=60)
    binary = out / 'egl-check'
    manifest = {'profile': 'kwin-wayland-v1', 'files': {'egl-check': {
        'sha256': hashlib.sha256(binary.read_bytes()).hexdigest(), 'size': binary.stat().st_size}},
        'source_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in (HERE / 'egl-check.c', HERE / 'build.py')},
        'protocol_sha256': protocols}
    path = out / 'manifest.json'
    path.write_text(json.dumps(manifest, indent=2) + '\n')
    print('Manifest SHA256:', hashlib.sha256(path.read_bytes()).hexdigest())


if __name__ == '__main__':
    main()
