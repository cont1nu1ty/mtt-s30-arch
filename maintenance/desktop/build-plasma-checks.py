#!/usr/bin/env python3
"""Build the v12 private Plasma/XWayland test bundle; never install or load it."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'builds/desktop-applications-v11-20261109'
BASE_SHA = '8b6f7a9f028bac894b34a206b17a9755470e45b88e5e2b923122eab64cd18f64'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kwin-work', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    work, out = args.kwin_work.resolve(), args.output.absolute()
    if out.exists() or sha(BASE / 'manifest.json') != BASE_SHA:
        raise ValueError('Need a new output and the verified v11 base manifest.')
    report = json.loads((work / 'result.json').read_text())
    if report.get('built') is not True or report.get('old_trees_restored') is not True or report.get('configure_libexecdir') != '/usr/lib':
        raise ValueError('The private KWin rebuild/restoration is incomplete.')
    base = json.loads((BASE / 'manifest.json').read_text())
    with tempfile.TemporaryDirectory(dir=out.parent) as temp:
        tmp = Path(temp); bundle = tmp / 'bundle'; bundle.mkdir()
        for name, meta in base['files'].items():
            path = BASE / name
            if sha(path) != meta['sha256'] or path.stat().st_size != meta['size']:
                raise ValueError('Changed v11 input: ' + name)
            target = bundle / name; target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
        for name in ('kwin_wayland', 'libkwin.so.6'):
            source = work / 'bundle' / name
            meta = report['new_binaries'][name]
            if sha(source) != meta['sha256'] or source.stat().st_size != meta['size']:
                raise ValueError('Changed rebuilt KWin: ' + name)
            shutil.copy2(source, bundle / 'kwin' / name)
        sources = {}
        for name in ('plasma_support.py', 'xwayland_support.py'):
            source = ROOT / 'maintenance/recovery' / name
            shutil.copyfile(source, bundle / name)
            sources[name] = sha(bundle / name)
        source = tmp / 'x11-check.cpp'
        shutil.copyfile(ROOT / 'maintenance/desktop/x11-check.cpp', source)
        sources[source.name] = sha(source)
        modules = ['x11', 'gl', 'xcb', 'xcb-dri3']
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', *modules], text=True))
        command = ['c++', '-std=c++17', '-O2', '-g', '-Wall', '-Wextra', '-Werror',
                   '-ffile-prefix-map=' + str(tmp) + '=/mtt-v12-check', str(source), '-ldl', '-pthread',
                   '-o', str(bundle / 'x11-check'), *flags]
        subprocess.run(command, check=True, timeout=60)
        qt_source = tmp / 'qt-check.cpp'
        shutil.copyfile(ROOT / 'maintenance/desktop/qt-check.cpp', qt_source)
        sources[qt_source.name] = sha(qt_source)
        qt_flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs',
                                  'Qt6Core', 'Qt6Gui', 'Qt6Quick'], text=True))
        qt_command = ['c++', '-std=c++17', '-O2', '-g', '-fPIC', '-Wall', '-Wextra', '-Werror',
                      '-ffile-prefix-map=' + str(tmp) + '=/mtt-v12-check', str(qt_source), '-ldl',
                      '-o', str(bundle / 'qt-check'), *qt_flags]
        subprocess.run(qt_command, check=True, timeout=60)
        metadata = {'profile': 'kwin-plasma-xwayland-v12', 'base_manifest_sha256': BASE_SHA,
                    'builder_sha256': sha(Path(__file__)), 'kwin_build_record_sha256': sha(work / 'result.json'),
                    'kwin_patch_sha256': report['patch_sha256'], 'source_sha256': sources,
                    'compiler': subprocess.check_output(['c++', '--version'], text=True),
                    'build_command': [arg.replace(str(tmp), '/mtt-v12-check') for arg in command],
                    'qt_build_command': [arg.replace(str(tmp), '/mtt-v12-check') for arg in qt_command],
                    'files': {str(p.relative_to(bundle)): {'sha256': sha(p), 'size': p.stat().st_size}
                              for p in sorted(bundle.rglob('*')) if p.is_file()}, 'hardware_tested': False}
        (bundle / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
        out.mkdir()
        try:
            bundle.replace(out)
        except OSError:
            out.rmdir()
            raise
    print('Bundle:', out)
    print('Manifest SHA256:', sha(out / 'manifest.json'))


if __name__ == '__main__':
    main()
