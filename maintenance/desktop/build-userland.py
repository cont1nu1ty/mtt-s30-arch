#!/usr/bin/env python3
"""Build a private KWin and package ABI-matched EGL; never install or open a GPU."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
SNAPSHOT = 'https://snapshot.ubuntu.com/ubuntu/20250516T000000Z/pool/main/m/mesa/'
SOURCES = {
    'kwin-6.8.2.tar.xz': ('https://download.kde.org/stable/plasma/6.8.2/',
        'ea5e68d957c7d70abed97222a592d4445fda29129e20942658badd224ee138b4'),
    'wayland-protocols-1.50-1-any.pkg.tar.zst': ('https://archive.archlinux.org/packages/w/wayland-protocols/',
        '9fc5d6f59513343bf20a994037591373e3d473f005c58c33ed089b01f52a9c84'),
    'plasma-wayland-protocols-1.23.0-1-any.pkg.tar.zst': ('https://archive.archlinux.org/packages/p/plasma-wayland-protocols/',
        '3f89f37dbb8c7a70eba54567764cb35e9e4fd253c803ef14bfb8425588b05ea7'),
    'libegl-mesa0_23.2.1-1ubuntu3.1~22.04.3_amd64.deb': (SNAPSHOT,
        '3f7066355233c54a82332c009169b8156de48e2be9f15b54cadfb0ab03f95122'),
    'libglapi-mesa_23.2.1-1ubuntu3.1~22.04.3_amd64.deb': (SNAPSHOT,
        '6a1a64062d386a0a9ca651057e369b1d418ceebb6c71584c2d0cda324166caea'),
}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(args, **kwargs):
    subprocess.run(args, check=True, **kwargs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--work', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--jobs', type=int, default=8)
    args = parser.parse_args()
    work, out = args.work.resolve(), args.output.resolve()
    if out.exists():
        raise RuntimeError('Output exists; use a new bundle directory.')
    work.mkdir(parents=True, exist_ok=True)
    for name, (prefix, expected) in SOURCES.items():
        path = work / name
        if not path.exists():
            temporary = path.with_suffix(path.suffix + '.download')
            urllib.request.urlretrieve(prefix + name, temporary)
            if sha(temporary) != expected:
                raise RuntimeError('Downloaded source checksum mismatch: ' + name)
            temporary.rename(path)
        if sha(path) != expected:
            raise RuntimeError('Source checksum mismatch: ' + name)

    deps, mesa = work / 'deps', work / 'ubuntu-mesa'
    deps.mkdir(exist_ok=True); mesa.mkdir(exist_ok=True)
    for name in SOURCES:
        if name.endswith('.pkg.tar.zst'):
            run(['bsdtar', '-xf', str(work / name), '-C', str(deps), 'usr'])
        elif name.endswith('.deb'):
            members = subprocess.check_output(['bsdtar', '-tf', str(work / name)], text=True).splitlines()
            data = next(n for n in members if n.startswith('data.tar.'))
            archive = work / (name + '.' + data)
            with archive.open('wb') as stream:
                run(['bsdtar', '-xOf', str(work / name), data], stdout=stream)
            run(['bsdtar', '-xf', str(archive), '-C', str(mesa)])
    for path in (deps / 'usr/share/pkgconfig').glob('*.pc'):
        path.write_text(path.read_text().replace('prefix=/usr', 'prefix=' + str(deps / 'usr')))

    source = work / 'kwin-6.8.2'
    if not source.exists():
        with tarfile.open(work / 'kwin-6.8.2.tar.xz') as archive:
            archive.extractall(work, filter='data')
    patch = ROOT / 'patches/kwin-6.8.2-s30-test.patch'
    with patch.open() as stream:
        reverse = subprocess.run(['patch', '--dry-run', '--batch', '--fuzz=0', '-R', '-p1'],
                                 stdin=stream, cwd=source, capture_output=True)
    if reverse.returncode != 0:
        with patch.open() as stream:
            run(['patch', '--batch', '--fuzz=0', '-p1'], stdin=stream, cwd=source)
    build = work / 'kwin-build'
    env = dict(os.environ, PKG_CONFIG_PATH=str(deps / 'usr/share/pkgconfig'))
    configure = ['cmake', '-S', str(source), '-B', str(build), '-G', 'Ninja',
                 '-DCMAKE_BUILD_TYPE=Release', '-DBUILD_TESTING=OFF', '-DKWIN_BUILD_KCMS=OFF',
                 '-DKWIN_BUILD_X11=ON', '-DCMAKE_INSTALL_PREFIX=/usr', '-DCMAKE_SKIP_RPATH=ON',
                 '-DPlasmaWaylandProtocols_DIR=' + str(deps / 'usr/share/cmake/PlasmaWaylandProtocols')]
    with (work / 'userland-configure.log').open('w') as log:
        run(configure, env=env, stdout=log, stderr=subprocess.STDOUT)
    with (work / 'userland-build.log').open('w') as log:
        run(['cmake', '--build', str(build), '--target', 'kwin_wayland', '-j', str(args.jobs)],
            stdout=log, stderr=subprocess.STDOUT)

    source_hash = hashlib.sha256((sha(ROOT / 'maintenance/desktop/egl-check.c') +
                                sha(ROOT / 'maintenance/desktop/build.py')).encode()).hexdigest()[:12]
    check_build = work / ('egl-check-' + source_hash)
    if not check_build.exists():
        run(['/usr/bin/python3', str(ROOT / 'maintenance/desktop/build.py'), '--output', str(check_build)])
    kwin = next(p for p in build.rglob('kwin_wayland') if p.is_file())
    core = next(p for p in build.rglob('libkwin.so.6.8.2') if p.is_file())
    lib = mesa / 'usr/lib/x86_64-linux-gnu'
    files = {'egl-check': check_build / 'egl-check', 'kwin/kwin_wayland': kwin,
             'kwin/libkwin.so.6': core, 'egl/libEGL_mesa.so.0': lib / 'libEGL_mesa.so.0.0.0',
             'egl/libglapi.so.0': lib / 'libglapi.so.0.0.0'}
    out.mkdir(parents=True)
    for name, source_file in files.items():
        target = out / name; target.parent.mkdir(exist_ok=True)
        shutil.copyfile(source_file, target)
        target.chmod(0o755 if name in ('egl-check', 'kwin/kwin_wayland') else 0o644)
        dynamic = subprocess.check_output(['readelf', '-d', str(target)], text=True)
        if '(RPATH)' in dynamic or '(RUNPATH)' in dynamic:
            raise RuntimeError('Bundle unexpectedly retains a library search path: ' + name)
    config = out / 'egl/50_mesa.json'
    config.write_text(json.dumps({'file_format_version': '1.0.0',
                                 'ICD': {'library_path': 'libEGL_mesa.so.0'}}, indent=2) + '\n')
    manifest = {'profile': 'kwin-wayland-v2', 'files': {
        str(p.relative_to(out)): {'sha256': sha(p), 'size': p.stat().st_size}
        for p in sorted(out.rglob('*')) if p.is_file()},
        'sources': {name: {'url': prefix + name, 'sha256': digest}
                    for name, (prefix, digest) in SOURCES.items()},
        'patch_sha256': sha(patch), 'builder_sha256': sha(__file__),
        'egl_check_manifest': json.loads((check_build / 'manifest.json').read_text()),
        'kwin_configure': configure, 'egl_dri_internal_version': '23.2.1-1ubuntu3.1~22.04.3',
        'hardware_tested': False}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Private userland bundle:', out)
    print('Manifest SHA256:', sha(out / 'manifest.json'))


if __name__ == '__main__':
    main()
