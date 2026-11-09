#!/usr/bin/env python3
"""Run the original and repaired Wayland swapchain destructors without a GPU."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import subprocess

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = Path(__file__).with_name('tests') / 'drawable-teardown.c'
ORIGINAL = ROOT / 'official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri/mtgpu_dri.so'
EXPECTED = {'original': '2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c',
            'candidate': '05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    output = args.output.resolve()
    binaries = {'original': ORIGINAL, 'candidate': args.candidate.resolve(strict=True)}
    for name, path in binaries.items():
        if hashlib.sha256(path.read_bytes()).hexdigest() != EXPECTED[name]:
            raise ValueError('Unreviewed library: ' + str(path))
    output.mkdir(parents=True)
    helper = output / 'drawable-teardown'
    subprocess.run(['cc', '-std=c11', '-Wall', '-Wextra', '-Werror', '-g',
                    '-fsanitize=address', str(FIXTURE), '-ldl', '-o', str(helper)], check=True)
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    env = {'PATH': os.defpath, 'LC_ALL': 'C',
           'ASAN_OPTIONS': 'detect_leaks=1:halt_on_error=1:exitcode=77:disable_coredump=1'}
    cases = []
    unload = {}
    for label, library in binaries.items():
        control = subprocess.run([str(helper), str(library), 'load-unload', '0'],
                                 env=env, text=True, capture_output=True, timeout=15)
        (output / f'{label}-load-unload.log').write_text(control.stdout + control.stderr)
        if control.returncode == 77:
            summary = re.search(r'SUMMARY: AddressSanitizer: (\d+) byte\(s\) leaked in (\d+) allocation\(s\)', control.stderr)
            if not summary or 'ERROR: AddressSanitizer:' in control.stderr:
                raise RuntimeError('Unexpected load/unload control failure: ' + label)
            unload[label] = {'leaked_bytes': int(summary[1]), 'allocations': int(summary[2])}
        elif control.returncode == 0:
            unload[label] = {'leaked_bytes': 0, 'allocations': 0}
        else:
            raise RuntimeError('Load/unload control failed: ' + label)
        for mode in ('complete', 'deleting'):
            for nodes in (1, 3):
                run = subprocess.run([str(helper), str(library), mode, str(nodes)],
                                     env=env, text=True, capture_output=True, timeout=15)
                log = output / f'{label}-{mode}-{nodes}.log'
                log.write_text(run.stdout + run.stderr)
                if label == 'original':
                    passed = run.returncode == 77 and 'attempting double-free' in run.stderr
                else:
                    passed = run.returncode == 0 and 'object ownership correct' in run.stdout
                if not passed:
                    raise RuntimeError('Unexpected teardown result: ' + str(log))
                cases.append({'library': label, 'destructor': mode, 'nodes': nodes, 'exit': run.returncode})
    if unload['candidate'] != unload['original']:
        raise RuntimeError('Unloading the DRI ELF changed the leak counts.')
    result = {'passed': True, 'cases': cases, 'load_unload_control': unload,
              'sha256': EXPECTED, 'gpu_opened': False}
    (output / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    print('All eight real-library lifetime cases passed.')


if __name__ == '__main__':
    main()
