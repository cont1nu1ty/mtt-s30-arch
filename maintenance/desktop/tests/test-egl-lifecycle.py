#!/usr/bin/env python3
"""Check lifecycle CLI bounds and repeated EGL creation with a CPU driver."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    binary = args.binary.resolve(strict=True)
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    env = {'PATH': os.defpath, 'LC_ALL': 'C', 'LIBGL_ALWAYS_SOFTWARE': '1',
           'MESA_LOADER_DRIVER_OVERRIDE': 'swrast',
           '__EGL_VENDOR_LIBRARY_FILENAMES': '/usr/share/glvnd/egl_vendor.d/50_mesa.json'}
    colors = (bytes((255, 0, 0, 255)), bytes((0, 255, 0, 255)),
              bytes((0, 0, 255, 255)), bytes((255, 255, 255, 255)))
    expected = b''.join(colors[(x // 16 + 3 * (y // 16) + 7) % 4]
                        for y in range(192) for x in range(256))
    cases = []
    for label, cycles in [('default', None), ('one', '1'), ('five', '5'), ('ten', '10')]:
        rgba = output / (label + '.rgba')
        command = [str(binary), 'software-surfaceless', '-', str(rgba)]
        if cycles is not None:
            command.append(cycles)
        run = subprocess.run(command, env=env, text=True, capture_output=True, timeout=30)
        (output / (label + '.log')).write_text(run.stdout + run.stderr)
        assert run.returncode == 0, (label, run.stderr)
        result = json.loads(run.stdout.splitlines()[-1])
        count = int(cycles or 1)
        assert result['passed'] and result['mode'] == 'surfaceless-software'
        assert result['completed_cycles'] == count and result['frames_per_cycle'] == 8
        assert result['frames'] == 8 * count and result['pixels_checked'] == 393216 * count
        assert result['presented'] == result['hardware_presentations'] == result['discarded'] == 0
        assert result['presentation_flags_all'] == 0 and rgba.read_bytes() == expected
        assert run.stdout.count('Lifecycle completed ') == (count if count > 1 else 0)
        cases.append({'case': label, 'exit': run.returncode, 'result': result})
    for index, invalid in enumerate(('0', '11', '-1', '+1', '', '2x', ' 2', '9999999999999999999999999')):
        rgba = output / ('invalid-' + str(index) + '.rgba')
        run = subprocess.run([str(binary), 'software-surfaceless', '-', str(rgba), invalid],
                             env=env, text=True, capture_output=True, timeout=5)
        assert run.returncode == 2 and 'CYCLES must be' in run.stderr
        assert not rgba.exists() and '"passed":true' not in run.stdout
        cases.append({'case': 'invalid-cycles', 'argument': invalid, 'exit': run.returncode})
    evidence = {'passed': True, 'cases': cases,
                'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
                'scope': 'CPU-only surfaceless lifetimes and CLI bounds. Wayland protocol lifetimes require the separate compositor control.'}
    (output / 'results.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print('12 lifecycle and input-boundary cases passed.')


if __name__ == '__main__':
    main()
