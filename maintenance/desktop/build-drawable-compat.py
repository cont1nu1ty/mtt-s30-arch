#!/usr/bin/env python3
"""Package the verified v9 userland with a private Wayland client DRI directory."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'builds/desktop-userland-fix8-20261106'
BASE_SHA = '041b3ad6f378a9ced7569a658a0e917cd72147ad3bcb68b27222054a7e5d5e30'
VENDOR = ROOT / 'official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri'
ORIGINAL_SHA = '2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c'
REPAIRED_SHA = '05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23'
SECONDARY_SHA = '0c8ddef50a68b20db4fcb1b5e91a5c74075fa0c5527b3a9b45cd93aeaec3532b'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def repair_wayland_destructors(original):
    """Keep one base cleanup in each WaylandSwapChain destructor of this exact ELF."""
    if sha(original) != ORIGINAL_SHA:
        raise ValueError('The official primary DRI driver changed.')
    data = bytearray(original)
    # The complete destructor ends in a tail call to the base destructor.
    # The deleting variant calls the base destructor and then sized delete.
    # Both have an extra earlier call on the same object. The file and virtual
    # offsets here coincide in this ELF's executable segment.
    for offset, expected in ((0x5A51A0, 'e8dbe7daff'), (0x5875E0, 'e89bc3dcff')):
        if data[offset:offset + 5] != bytes.fromhex(expected):
            raise ValueError(f'Unexpected Wayland destructor instruction at {offset:#x}.')
        data[offset:offset + 5] = bytes.fromhex('0f1f440000')
    if sha(data) != REPAIRED_SHA:
        raise ValueError('Unexpected private DRI output.')
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    out = parser.parse_args().output.absolute()
    base_bytes = (BASE / 'manifest.json').read_bytes()
    if sha(base_bytes) != BASE_SHA:
        raise ValueError('The v9 base manifest changed.')
    base = json.loads(base_bytes)
    with tempfile.TemporaryDirectory(dir=out.parent) as tmp:
        tmp = Path(tmp)
        bundle = tmp / 'bundle'
        for name, meta in base['files'].items():
            target = bundle / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(BASE / name, target)
            if sha(target.read_bytes()) != meta['sha256']:
                raise ValueError('Changed v9 payload: ' + name)
        dri = bundle / 'client-dri'
        dri.mkdir()
        secondary = (VENDOR / 'musa_dri.so').read_bytes()
        if sha(secondary) != SECONDARY_SHA:
            raise ValueError('The secondary MUSA driver changed.')
        (dri / 'musa_dri.so').write_bytes(secondary)
        primary = repair_wayland_destructors((VENDOR / 'mtgpu_dri.so').read_bytes())
        (dri / 'mtgpu_dri.so').write_bytes(primary)
        files = {}
        for path in sorted(bundle.rglob('*')):
            if path.is_file():
                data = path.read_bytes()
                files[str(path.relative_to(bundle))] = {'size': len(data), 'sha256': sha(data)}
        manifest = {'profile': 'kwin-wayland-v10', 'base_manifest_sha256': BASE_SHA,
                    'builder_sha256': sha(Path(__file__).read_bytes()), 'original_dri_sha256': ORIGINAL_SHA,
                    'files': files, 'hardware_tested': False}
        metadata = (json.dumps(manifest, indent=2) + '\n').encode()
        (bundle / 'manifest.json').write_bytes(metadata)
        # Never replace an existing bundle. A failing copy leaves no partial manifest.
        out.mkdir()
        try:
            bundle.replace(out)
        except OSError:
            out.rmdir()
            raise
    print('Bundle:', out)
    print('Manifest SHA256:', sha(metadata))


if __name__ == '__main__':
    main()
