#!/usr/bin/env python3
"""Clean-build private KWin and retain the reviewed v7 bundle's client EGL.

Uses hash-pinned local source archives; never installs or opens a GPU device.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'builds/desktop-userland-fix6-20261104'
BASE_SHA = 'd6220525b89a82a46b4e2d4f15b6cfd5fc6a0a0cc20a3b1cbe123bcf4d2811c6'
SOURCES = {
    'kwin-6.8.2.tar.xz': 'ea5e68d957c7d70abed97222a592d4445fda29129e20942658badd224ee138b4',
    'wayland-protocols-1.50-1-any.pkg.tar.zst': '9fc5d6f59513343bf20a994037591373e3d473f005c58c33ed089b01f52a9c84',
    'plasma-wayland-protocols-1.23.0-1-any.pkg.tar.zst': '3f89f37dbb8c7a70eba54567764cb35e9e4fd253c803ef14bfb8425588b05ea7',
}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    builder_bytes = Path(__file__).read_bytes()
    builder_sha = hashlib.sha256(builder_bytes).hexdigest()
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('work', 'output', 'source-cache'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--jobs', type=int, default=8)
    args = parser.parse_args()
    work, out, cache = args.work.resolve(), args.output.resolve(), args.source_cache.resolve()
    if work.exists() or out.exists() or args.jobs < 1:
        raise RuntimeError('Use new work/output directories and positive jobs.')
    base_bytes = (BASE / 'manifest.json').read_bytes()
    if hashlib.sha256(base_bytes).hexdigest() != BASE_SHA:
        raise RuntimeError('Reviewed base manifest changed.')
    base = json.loads(base_bytes)
    for name, metadata in base['files'].items():
        if sha(BASE / name) != metadata['sha256']:
            raise RuntimeError('Reviewed base file changed: ' + name)
    for name, expected in SOURCES.items():
        if sha(cache / name) != expected:
            raise RuntimeError('Source archive changed: ' + name)
    patches = [ROOT / 'patches' / name for name in (
        'kwin-6.8.2-s30-test.patch', 'kwin-6.8.2-mtgpu-format-context.patch',
        'kwin-6.8.2-mtgpu-import-formats.patch')]
    patch_inputs = {}
    for patch in patches:
        if not patch.is_file():
            raise RuntimeError('Missing reviewed patch: ' + str(patch))
        patch_inputs[patch.name] = patch.read_bytes()
    patch_hashes = {name: hashlib.sha256(data).hexdigest()
                    for name, data in patch_inputs.items()}
    work.mkdir(parents=True)
    # Preserve exactly the bytes used below, even if maintenance files change
    # while a long build is running.
    (work / 'build-kwin-compat.py').write_bytes(builder_bytes)
    (work / 'patches').mkdir()
    for name, data in patch_inputs.items():
        (work / 'patches' / name).write_bytes(data)
    copied_source_hashes = {}
    for name, expected in SOURCES.items():
        shutil.copyfile(cache / name, work / name)
        copied_source_hashes[name] = sha(work / name)
        if copied_source_hashes[name] != expected:
            raise RuntimeError('Copied source archive changed: ' + name)
    with tarfile.open(work / 'kwin-6.8.2.tar.xz') as archive:
        archive.extractall(work, filter='data')
    source, deps = work / 'kwin-6.8.2', work / 'deps'
    deps.mkdir()
    for name in SOURCES:
        if name.endswith('.pkg.tar.zst'):
            subprocess.run(['bsdtar', '-xf', str(work / name), '-C', str(deps), 'usr'], check=True)
    for path in (deps / 'usr/share/pkgconfig').glob('*.pc'):
        path.write_text(path.read_text().replace('prefix=/usr', 'prefix=' + str(deps / 'usr')))
    with (work / 'source-prepare.log').open('w') as log:
        for patch_bytes in patch_inputs.values():
            subprocess.run(['patch', '--batch', '--fuzz=0', '-p1'], input=patch_bytes,
                           cwd=source, stdout=log, stderr=subprocess.STDOUT, check=True)
    build = work / 'kwin-build'
    env = dict(os.environ, PKG_CONFIG_PATH=str(deps / 'usr/share/pkgconfig'))
    configure = ['cmake', '-S', str(source), '-B', str(build), '-G', 'Ninja',
                 '-DCMAKE_BUILD_TYPE=Release', '-DBUILD_TESTING=OFF', '-DKWIN_BUILD_KCMS=OFF',
                 '-DKWIN_BUILD_X11=ON', '-DCMAKE_INSTALL_PREFIX=/usr', '-DCMAKE_SKIP_RPATH=ON',
                 '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
                 '-DPlasmaWaylandProtocols_DIR=' + str(deps / 'usr/share/cmake/PlasmaWaylandProtocols')]
    with (work / 'kwin-configure.log').open('w') as log:
        subprocess.run(configure, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    with (work / 'kwin-build.log').open('w') as log:
        subprocess.run(['cmake', '--build', str(build), '--target', 'kwin_wayland', '-j', str(args.jobs)],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    out.mkdir(parents=True)
    replacements = {'kwin/kwin_wayland': build / 'bin/kwin_wayland',
                    'kwin/libkwin.so.6': build / 'bin/libkwin.so.6.8.2'}
    for name, metadata in base['files'].items():
        target = out / name
        target.parent.mkdir(exist_ok=True)
        original = replacements.get(name, BASE / name)
        shutil.copyfile(original, target)
        if name not in replacements and (target.stat().st_size != metadata['size']
                                         or sha(target) != metadata['sha256']):
            raise RuntimeError('Copied reviewed base file changed: ' + name)
        target.chmod(0o755 if name in ('egl-check', 'kwin/kwin_wayland') else 0o644)
        if name != 'egl/50_mesa.json':
            dynamic = subprocess.check_output(['readelf', '-d', str(target)], text=True)
            if 'RPATH' in dynamic or 'RUNPATH' in dynamic:
                raise RuntimeError('Embedded build library search path: ' + name)
    manifest = {
        'profile': 'kwin-wayland-v8',
        'files': {str(p.relative_to(out)): {'sha256': sha(p), 'size': p.stat().st_size}
                  for p in sorted(out.rglob('*')) if p.is_file()},
        'base_manifest_sha256': BASE_SHA, 'source_archives': copied_source_hashes,
        'patches': patch_hashes, 'builder_sha256': builder_sha,
        'kwin_configure': configure, 'client_egl_unchanged': True,
        'vendor_binary_modified': False, 'hardware_tested': False,
    }
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Bundle:', out)
    print('Manifest SHA256:', sha(out / 'manifest.json'))


if __name__ == '__main__':
    main()
