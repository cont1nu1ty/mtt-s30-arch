#!/usr/bin/env python3
"""Replay the real EGL vendor GL lookup and TLS dispatch with CPU sentinel functions."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import subprocess

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = Path(__file__).resolve().parent / 'tests/gl-dispatch-test.c'
CLIENT = FIXTURE.parent.parent / 'egl-check.c'
VENDOR = ROOT / 'official/driver-3.1.0/usr/lib/x86_64-linux-gnu/libglapi_musa.so.0.0.0'
VENDOR_SHA = 'c130e2756e374e5ef6a843a0e9d93bfba1674412249a4a426858e2f381acd569'
BASELINE_SHA = '1745f0903656a0a4a6b764313fb56eff988ba7855ecd66278e1128153ce2f6dc'
MESA_GLAPI_SHA = '3b796b01bb3b6d8fa8bd0b970258fd2c284841fd3ded0e82f684adc06ba2f1cb'
MARKER = 'MTT compatibility: Wayland GLES dispatch '


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def flush_get_offset(library):
    symbols = subprocess.check_output(['nm', '-an', '--defined-only', str(library)], text=True).splitlines()
    matching = [row.split()[0] for row in symbols if row.split()[-1] == 'dri2_gl_flush_get']
    if len(matching) != 1:
        raise ValueError(f'Expected one DRI2 internal glFlush resolver in {library}')
    return matching[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, help='Omit to prepare and check only the v8 negative control')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    baseline = args.baseline.resolve(strict=True)
    if digest(baseline) != BASELINE_SHA or digest(VENDOR) != VENDOR_SHA:
        raise ValueError('Wrong v8 baseline or official 3.1.0 GL API library')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    binary = output / 'dispatch-test'
    build = ['cc', '-std=gnu11', '-O2', '-Wall', '-Wextra', '-Werror', str(FIXTURE), '-ldl', '-pthread', '-o', str(binary)]
    subprocess.run(build, check=True)
    entry_names = sorted(set(re.findall(r'\b(gl[A-Z]\w*)\s*\(', CLIENT.read_text())))
    cases = [('baseline-vendor-only', baseline, 'baseline', str(VENDOR))]
    if args.candidate:
        candidate = args.candidate.resolve(strict=True)
        cases.extend([
            ('vendor-dispatch', candidate, 'vendor', str(VENDOR)),
            ('ordinary-dispatch', candidate, 'ordinary', None),
            ('missing-library', candidate, 'unavailable', str(output / 'no-such-library.so')),
            ('missing-resolver', candidate, 'unavailable', str(candidate.parent / 'libglapi.so.0')),
            ('relative-path', candidate, 'unavailable', 'libglapi_musa.so.0'),
        ])
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    results = []
    for name, library, mode, path in cases:
        ordinary = library.parent / 'libglapi.so.0'
        if digest(ordinary) != MESA_GLAPI_SHA:
            raise ValueError('Wrong ordinary Mesa GL API')
        env = {'PATH': '/usr/bin:/usr/sbin', 'LC_ALL': 'C', 'EGL_LOG_LEVEL': 'debug', 'LD_LIBRARY_PATH': str(library.parent)}
        if path is not None:
            env['MTT_S30_WAYLAND_GLAPI'] = path
        argv = [str(binary), mode, str(library), str(ordinary), str(VENDOR), flush_get_offset(library), *entry_names]
        run = subprocess.run(argv, env=env, text=True, capture_output=True, timeout=15)
        lines = [line for line in run.stderr.splitlines() if MARKER in line]
        marker_ok = (len(lines) == 1 and lines[0].endswith(MARKER + str(VENDOR))) if mode == 'vendor' else not lines
        (output / (name + '.stdout')).write_text(run.stdout)
        (output / (name + '.stderr')).write_text(run.stderr)
        results.append(dict(name=name, exit=run.returncode, marker_verified=marker_ok,
                            library_sha256=digest(library), argv=argv, environment=env, stdout=run.stdout, stderr=run.stderr))
    passed = all(r['exit'] == 0 and r['marker_verified'] for r in results)
    report = dict(passed=passed, cases=results, case_count=len(results), gl_entries=entry_names,
                  ordinary_glapi_sha256=MESA_GLAPI_SHA, vendor_glapi_sha256=VENDOR_SHA,
                  source_sha256=digest(FIXTURE), runner_sha256=digest(Path(__file__)), client_sha256=digest(CLIENT),
                  build=build, scope='Real vendor ABI, library stubs and TLS. Sentinel dispatch tables. No EGL display, real context, DRI driver, GPU or Wayland connection.')
    (output / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    if not passed:
        raise RuntimeError('Failed dispatch cases: ' + repr([(r['name'], r['exit'], r['stderr'][-400:]) for r in results if r['exit'] or not r['marker_verified']]))
    print(f"{len(results)} dispatch cases passed, {len(entry_names)} client GL entry points checked; {output / 'results.json'}")


if __name__ == '__main__':
    main()
