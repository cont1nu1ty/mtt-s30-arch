#!/usr/bin/env python3
"""Read-only inspection of an upgraded boot target. Never starts a GPU test."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('runner', HERE / 'test-once.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


def check(condition, message):
    if not condition:
        raise RuntimeError(message)


def references(esp, text):
    images, options = [], []
    for line in text.splitlines():
        fields = shlex.split(line, comments=True)
        if not fields:
            continue
        if fields[0] in ('linux', 'initrd', 'efi'):
            check(len(fields) == 2, 'Invalid boot image reference.')
            path = (esp / fields[1].lstrip('/')).resolve()
            check(path.is_relative_to(esp) and path.is_file(), 'Missing or escaped boot image: ' + fields[1])
            images.append((fields[0], path))
        if fields[0] == 'options':
            options.extend(fields[1:])
    check(sum(kind == 'linux' for kind, _ in images) == 1 and
          any(kind == 'initrd' for kind, _ in images), 'Expected one kernel and an initramfs.')
    check(not any(kind == 'efi' for kind, _ in images), 'UKI requires a separate review.')
    return images, options


def check_initramfs(listing, kernel):
    check(not re.search(r'\bmtgpu\.ko(?:\.(?:zst|xz|gz))?\b', listing), 'mtgpu found in initramfs.')
    versions = sorted(set(re.findall(r'(?:usr/)?lib/modules/([^/\s]+)/', listing)))
    check(versions == [kernel], 'Initramfs kernel versions mismatch: ' + repr(versions))
    return versions


def inspect(kernel):
    check(os.geteuid() == 0, 'Run with sudo in your terminal; do not send a password.')
    check(re.fullmatch(r'[0-9][A-Za-z0-9.+_-]+', kernel), 'Invalid kernel release.')
    esp = Path(runner.output(['bootctl', '--print-esp-path'])).resolve()
    check(esp == Path('/efi'), 'Unexpected ESP; review required.')
    runner.check_efi_overrides()
    entries = json.loads(runner.output(['bootctl', 'list', '--json=short', '--no-pager']))
    defaults = [e for e in entries if e.get('isDefault')]
    check(len(defaults) == 1, 'Cannot identify one default boot entry.')
    default = defaults[0]
    check(default.get('type') == 'type1' and default.get('id', '').endswith('-' + kernel + '.conf'),
          'Default boot target does not match the requested kernel.')
    selected = [default] + [e for e in entries if e.get('id', '').endswith('-' + kernel + '-fallback.conf')]
    check(len(selected) == 2, 'Expected normal and fallback entries for this kernel.')
    installed = Path('/usr/lib/modules') / kernel / 'vmlinuz'
    check(installed.is_file(), 'Installed kernel image is missing.')
    package = runner.output(['pacman', '-Q', 'linux', 'linux-headers'])
    root_options = [x for x in Path('/proc/cmdline').read_text().split() if x.startswith(('root=', 'rootflags=', 'rootfstype='))]
    check(any(x.startswith('root=') for x in root_options), 'Current root argument is missing.')
    report = {'running_kernel': os.uname().release, 'target_kernel': kernel,
              'target_kernel_has_booted': os.uname().release == kernel,
              'scope': 'Boot-file consistency only; not a successful boot test or historical EFI recovery verification.',
              'packages': package, 'default_entry': default['id'], 'entries': [],
              'boot_files_verified': False, 'driver_loaded': Path('/sys/module/mtgpu').exists()}
    hashes = {}
    for entry in selected:
        name = entry['id']
        check(Path(name).name == name and entry.get('type') == 'type1', 'Unexpected entry identifier or type.')
        path = esp / 'loader/entries' / name
        hashes[path] = runner.sha(path)
        images, options = references(esp, path.read_text())
        check(sorted(x for x in options if x.startswith(('root=', 'rootflags=', 'rootfstype='))) == sorted(root_options),
              'Root filesystem arguments changed.')
        detail = {'id': name, 'images': []}
        for kind, image in images:
            hashes[image] = runner.sha(image)
            item = {'type': kind, 'path': str(image), 'sha256': hashes[image], 'bytes': image.stat().st_size}
            if kind == 'linux':
                check(hashes[image] == runner.sha(installed), 'ESP kernel differs from installed kernel.')
            else:
                item['module_versions'] = check_initramfs(runner.output(['lsinitrd', str(image)], timeout=90), kernel)
                item['mtgpu_present'] = False
            detail['images'].append(item)
        report['entries'].append(detail)
    check(all(runner.sha(p) == value for p, value in hashes.items()), 'Boot files changed during inspection.')
    report['boot_files_verified'] = True
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kernel', required=True)
    args = parser.parse_args()
    result = inspect(args.kernel)
    fd, name = tempfile.mkstemp(prefix='mtt-s30-next-boot-', suffix='.json', dir='/var/tmp')
    with os.fdopen(fd, 'w') as out:
        json.dump(result, out, indent=2)
        out.write('\n')
        os.fchmod(out.fileno(), 0o644)
    print('Read-only boot-file inspection passed. No driver loaded, no boot files changed, no reboot requested.')
    print('Target kernel has booted:', result['target_kernel_has_booted'])
    print('Summary:', name)


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        raise SystemExit('STOP: ' + str(error))
