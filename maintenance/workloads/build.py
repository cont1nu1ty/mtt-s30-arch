#!/usr/bin/env python3
"""Build reviewed workloads and software reference. Never accesses a GPU."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import struct
import subprocess

HERE = Path(__file__).resolve().parent


def run(args):
    subprocess.run(args, check=True, timeout=90)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    arrays = []
    for suffix, name in [('vert', 'vertex'), ('frag', 'fragment')]:
        spv = out / (name + '.spv')
        run(['glslangValidator', '-V', '--target-env', 'vulkan1.0',
             str(HERE / ('pattern.' + suffix)), '-o', str(spv)])
        run(['spirv-val', '--target-env', 'vulkan1.0', str(spv)])
        raw = spv.read_bytes()
        words = struct.unpack('<' + 'I' * (len(raw) // 4), raw)
        arrays.append('static const uint32_t ' + name + '_spv[] = {' +
                      ','.join(hex(x) for x in words) + '};\n')
    (out / 'shaders.h').write_text(''.join(arrays))
    for source, libraries in [('vk-offscreen', ['vulkan']),
                              ('h264-check', ['libavcodec', 'libavformat', 'libavutil'])]:
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', *libraries], text=True))
        run(['cc', '-std=c11', '-O2', '-g', '-Wall', '-Wextra', '-Werror',
             '-I' + str(out), str(HERE / (source + '.c')), '-o', str(out / source), *flags])
    run(['ffmpeg', '-nostdin', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi',
         '-i', 'testsrc2=size=320x192:rate=24', '-frames:v', '48', '-an',
         '-c:v', 'libx264', '-threads:v', '1', '-pix_fmt', 'yuv420p', '-profile:v', 'high',
         '-preset', 'medium', '-crf', '20', '-g', '12', '-bf', '2', '-f', 'h264', str(out / 'clip.h264')])
    run(['ffmpeg', '-nostdin', '-hide_banner', '-loglevel', 'error', '-hwaccel', 'none',
         '-threads:v', '1', '-c:v', 'h264', '-i', str(out / 'clip.h264'), '-an',
         '-pix_fmt', 'nv12', '-c:v', 'rawvideo', '-threads:v', '1', '-f', 'rawvideo', str(out / 'reference.nv12')])
    assert (out / 'reference.nv12').stat().st_size == 320 * 192 * 3 // 2 * 48
    names = ['vk-offscreen', 'h264-check', 'clip.h264', 'reference.nv12']
    manifest = {'profile': 'render-decode-v1', 'files': {
        name: {'sha256': hashlib.sha256((out / name).read_bytes()).hexdigest(),
               'size': (out / name).stat().st_size} for name in names},
        'source_sha256': {f.name: hashlib.sha256(f.read_bytes()).hexdigest()
                          for f in sorted(HERE.iterdir()) if f.is_file()},
        'video': {'codec': 'h264', 'width': 320, 'height': 192, 'frames': 48,
                  'comparison': 'exact NV12 bytes after decoding'},
        'render': {'width': 128, 'height': 96, 'frames': 8, 'comparison': 'exact RGBA8 pixels'}}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Manifest SHA256:', hashlib.sha256((out / 'manifest.json').read_bytes()).hexdigest())


if __name__ == '__main__':
    main()
