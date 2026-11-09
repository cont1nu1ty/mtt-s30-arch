#!/usr/bin/env python3
"""Build the private Wayland EGL loader with the mtgpu ABI and GLES adapters.

Only writes project artifacts. Never installs packages or opens a GPU device.
Source hashes are verified against the signed Ubuntu snapshot Sources index.
"""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'builds/desktop-userland-fix7-20261104'
BASE_SHA = '0451e520e6bc2372c9165e110f9358ca1bff06e56fa4d01e4dfba1ffa4254ae1'
URL = 'https://snapshot.ubuntu.com/ubuntu/20250516T000000Z/pool/main/m/mesa/'
SOURCES = {
    'mesa_23.2.1.orig.tar.gz': 'c1458ab511b87d60644b2c46d67f7d9d5c0e3db691db6aae11762b1cc5b43ca0',
    'mesa_23.2.1-1ubuntu3.1~22.04.3.diff.gz': 'f43f7e603db34bb4f8fd8b41be102d112c23042e769d94a0d78fee0ee6ee7fd2',
}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    builder = Path(__file__).read_bytes()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--source-cache', type=Path)
    parser.add_argument('--python-bin', type=Path, required=True, help='Directory containing python3 with Mako and packaging')
    parser.add_argument('--protocol-pkgconfig', type=Path, required=True)
    parser.add_argument('--jobs', type=int, default=8)
    args = parser.parse_args()
    work, out = args.work.resolve(), args.output.resolve()
    if out.exists() or work.exists() or args.jobs < 1:
        raise RuntimeError('Use new work/output directories and positive jobs.')
    base_bytes = (BASE / 'manifest.json').read_bytes()
    if hashlib.sha256(base_bytes).hexdigest() != BASE_SHA:
        raise RuntimeError('Reviewed KWin bundle manifest changed.')
    base = json.loads(base_bytes)
    for name, metadata in base['files'].items():
        if sha(BASE / name) != metadata['sha256']:
            raise RuntimeError('Reviewed base file changed: ' + name)
    work.mkdir(parents=True)
    (work / 'build-egl-compat.py').write_bytes(builder)
    patches = work / 'patches'
    patches.mkdir()
    patch_names = (
        'mesa-23.2.1-mtgpu-image-lookup-v1.patch', 'mesa-c11-glibc-once.patch',
        'mesa-23.2.1-mtgpu-screen-abi.patch', 'mesa-23.2.1-dri-config-bounds.patch',
        'mesa-23.2.1-mtgpu-display-abi.patch', 'mesa-23.2.1-mtgpu-gl-dispatch.patch',
    )
    patch_inputs = {name: (ROOT / 'patches' / name).read_bytes() for name in patch_names}
    for name, data in patch_inputs.items():
        (patches / name).write_bytes(data)
    for name, digest in SOURCES.items():
        path = work / name
        if args.source_cache and (args.source_cache / name).is_file():
            shutil.copyfile(args.source_cache / name, path)
        else:
            urllib.request.urlretrieve(URL + name, path)
        if sha(path) != digest:
            raise RuntimeError('Source checksum mismatch: ' + name)
    with tarfile.open(work / 'mesa_23.2.1.orig.tar.gz') as archive:
        archive.extractall(work, filter='data')
    source = work / 'mesa-23.2.1'
    with (work / 'source-prepare.log').open('w') as log:
        def apply(data):
            subprocess.run(['patch', '--batch', '--fuzz=0', '-p1'], input=data,
                           cwd=source, stdout=log, stderr=subprocess.STDOUT, check=True)
        apply(gzip.decompress((work / 'mesa_23.2.1-1ubuntu3.1~22.04.3.diff.gz').read_bytes()))
        for line in (source / 'debian/patches/series').read_text().splitlines():
            name = line.split('#', 1)[0].strip()
            if name:
                apply((source / 'debian/patches' / name).read_bytes())
        for data in patch_inputs.values():
            apply(data)
    # Follow this exact source package's debian/rules (override_dh_auto_configure).
    # Do not substitute a version from a different release or remove the DRI check.
    version = re.match(r'mesa \(([^)]+)\)', (source / 'debian/changelog').read_text()).group(1)
    if version != '23.2.1-1ubuntu3.1~22.04.3':
        raise RuntimeError('Unexpected Ubuntu source revision.')
    (source / 'VERSION').write_text(version + '\n')
    env = dict(os.environ, PATH=str(args.python_bin.resolve()) + ':' + os.environ['PATH'],
               PKG_CONFIG_PATH=str(args.protocol_pkgconfig.resolve()))
    configure = ['meson', 'setup', str(work / 'mesa-build'), str(source), '--buildtype=debugoptimized',
                 '--prefix=/usr', '-Dplatforms=wayland', '-Dgallium-drivers=swrast', '-Dvulkan-drivers=',
                 '-Degl=enabled', '-Dgbm=enabled', '-Dglx=disabled', '-Dgles1=disabled', '-Dgles2=enabled',
                 '-Dopengl=true', '-Dllvm=disabled', '-Dshared-glapi=enabled', '-Dglvnd=true',
                 '-Dlibunwind=disabled', '-Dvalgrind=disabled', '-Dbuild-tests=false']
    with (work / 'egl-configure.log').open('w') as log:
        subprocess.run(configure, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    with (work / 'egl-build.log').open('w') as log:
        subprocess.run(['ninja', '-C', str(work / 'mesa-build'), '-j', str(args.jobs),
                        'src/egl/libEGL_mesa.so.0.0.0'], env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    out.mkdir(parents=True)
    for name in base['files']:
        path = out / name
        path.parent.mkdir(exist_ok=True)
        original = BASE / name
        if name == 'egl/libEGL_mesa.so.0':
            original = work / 'mesa-build/src/egl/libEGL_mesa.so.0.0.0'
        shutil.copyfile(original, path)
        if original == BASE / name and sha(path) != base['files'][name]['sha256']:
            raise RuntimeError('Staged base file changed: ' + name)
        path.chmod(0o755 if name in ('egl-check', 'kwin/kwin_wayland') else 0o644)
        if name != 'egl/50_mesa.json':
            if name == 'egl/libEGL_mesa.so.0':
                # Meson build-tree artifacts carry paths to sibling build libs.
                # Remove those from this private staged copy, as installation would.
                subprocess.run(['patchelf', '--remove-rpath', str(path)], check=True)
            dynamic = subprocess.check_output(['readelf', '-d', str(path)], text=True)
            if 'RPATH' in dynamic or 'RUNPATH' in dynamic:
                raise RuntimeError('Embedded build library search path: ' + name)
    manifest = {'profile': 'kwin-wayland-v9', 'files': {
        str(p.relative_to(out)): {'sha256': sha(p), 'size': p.stat().st_size}
        for p in sorted(out.rglob('*')) if p.is_file()},
        'base_manifest_sha256': BASE_SHA, 'sources': SOURCES, 'source_url': URL,
        'patches': {name: hashlib.sha256(data).hexdigest() for name, data in patch_inputs.items()},
        'builder_sha256': hashlib.sha256(builder).hexdigest(),
        'c11_upstream_commit': '179e744f7577d98df7c79d7324c22acfb32a0154',
        'configure': configure, 'dri_internal_version': version,
        'abi_version_check_bypassed': False, 'hardware_tested': False}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Bundle:', out)
    print('Manifest SHA256:', sha(out / 'manifest.json'))


if __name__ == '__main__':
    main()
