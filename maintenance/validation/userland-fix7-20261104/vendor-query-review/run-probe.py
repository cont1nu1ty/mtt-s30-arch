#!/usr/bin/env python3
"""Pinned CPU replay; no dlopen, ELF initialization, actual TLS or GPU access."""
from pathlib import Path
import hashlib
import json
import re
import resource
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
VENDOR = ROOT / 'official/driver-3.1.0/usr/lib/x86_64-linux-gnu'
EXPECTED = {
    'libEGL_mtgpu.so.0.0.0': '0a9460529f715037c0db589cefc5fd864e2915c7b373cc0f37b32ec70a0500b3',
    'dri/mtgpu_dri.so': '2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c',
    'libmusa_dri_support.so.1.0.0': 'bea665953469d99a2c15b72bb6a38724361d4d8bf311291c59f691c1bb500de1',
}
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
for name, expected in EXPECTED.items():
    if sha(VENDOR / name) != expected:
        raise RuntimeError('Changed reviewed vendor binary: ' + name)
subprocess.run(['cc', '-O2', '-Wall', '-Wextra', '-Werror', str(HERE / 'egl-query-probe.c'),
                '-o', str(HERE / 'egl-query-probe')], check=True, timeout=30)
resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
run = subprocess.run([str(HERE / 'egl-query-probe'), *[str(VENDOR / name) for name in EXPECTED]],
                     capture_output=True, text=True, check=True, timeout=10)
r = json.loads(run.stdout)
assert r['guard_enabled'] and r['original_instruction_bytes_unchanged'] and r['egl_wrapper_no_cache_22_18_22']
assert r['secondary_bind_tls_calls'] == r['secondary_unbind_tls_calls'] == 0
assert r['secondary_bind_calls'] == 1
assert r['before_secondary_bind'] == r['after_secondary_bind']
assert len(r['synthetic_primary_tls_formats']) == 18
table = json.loads((HERE / 'import-format-table.json').read_text())
assert r['synthetic_primary_tls_formats'] == [entry['value'] for entry in table['entries']]
assert hashlib.sha256((VENDOR / 'dri/mtgpu_dri.so').read_bytes()[0xc1c420:0xc1c420+18*12]).hexdigest() == table['table_sha256']
# Compare against actual current/accepted diagnostics, not a synthesized test list.
log = Path('/var/tmp/mtt-s30-results-20261104-200750/kwin.log').read_text()
line = next(line for line in log.splitlines() if 'context import formats before' in line)
current = set(int(h, 16) for h in re.findall(r'0x([0-9a-f]+)', line.split(' current ')[1].split(' accepted ')[0]))
before = set(int(h, 16) for h in re.findall(r'0x([0-9a-f]+)', line.split(' before ')[1].split(' current ')[0]))
assert current == set(r['after_primary_modifiers'])
assert before == set(r['before_secondary_bind'])
primary = set(r['synthetic_primary_tls_formats'])
decode = lambda value: value.to_bytes(4, 'little').decode('ascii')
r['runtime_before_exactly_matches_secondary_fixture'] = True
r['runtime_current_exactly_matches_secondary_formats_primary_modifiers'] = True
r['runtime_formats_after_import_table_intersection'] = sorted(map(decode, current & primary))
r['runtime_formats_removed_by_import_table'] = sorted(map(decode, current - primary))
assert r['runtime_formats_removed_by_import_table'] == ['AB30', 'XB24']
r['vendor_sha256'] = EXPECTED
r['source_sha256'] = sha(HERE / 'egl-query-probe.c')
r['tool_sha256'] = sha(Path(__file__))
r['boundaries'] = [
    'Original query and secondary bind/unbind instruction bytes; no vendor file or code-byte modification.',
    'No dlopen, ELF constructors, driver/EGL initialization, GPU node opening, real EGL context or real TLS.',
    'TLS resolver storage and downstream secondary bind/unbind are fixtures; GOT/global data in anonymous ELF image point to fixtures.',
    'Secondary mask all 31 enabled comes from historical 20261104-112910 client; it matches latest public before list exactly.',
    'Native kind 4 is a fixture for modifier queries; no live KWin private screen/context/TLS was read.',
    'Real S30 hardware success remains unproven; import-table membership alone is not sufficient for successful image import.',
]
for name, expected in EXPECTED.items():
    assert sha(VENDOR / name) == expected
(HERE / 'egl-query-probe.json').write_text(json.dumps(r, indent=2) + '\n')
print('Original-byte CPU query/bind replay passed; current 8-format set reproduced exactly.')
print('Import-table intersection:', r['runtime_formats_after_import_table_intersection'])
print('Removed:', r['runtime_formats_removed_by_import_table'])
