#!/usr/bin/env python3
"""Export only maintained sources against the authenticated vendor extraction."""
from pathlib import Path
import difflib, gzip
ROOT=Path(__file__).resolve().parent.parent
base=ROOT/'official/driver-3.1.0/usr/src/mtgpu-3.1.0'
work=ROOT/'work/mtgpu-3.1.0'
paths=set()
for root in (base,work):
 for p in root.rglob('*'):
  rel=p.relative_to(root)
  if p.is_file() and not p.is_symlink() and (p.suffix in ('.c','.h') or str(rel) in ('Makefile','conftest','dkms.conf')):
   if p.name in ('conftest.h','mtgpu.mod.c','.module-common.c'):continue
   if p.name.startswith('conftest_'):continue
   paths.add(rel)
output=[]
for rel in sorted(paths):
 a=base/rel;b=work/rel
 before=a.read_bytes() if a.exists() else b''
 if str(rel)=='conftest':before=gzip.decompress(before.split(b'\n',48)[48])
 after=b.read_bytes() if b.exists() else b''
 if before==after:continue
 output.extend(difflib.unified_diff(before.decode().splitlines(True),after.decode().splitlines(True),
  fromfile='a/'+str(rel) if a.exists() else '/dev/null',tofile='b/'+str(rel) if b.exists() else '/dev/null'))
p=ROOT/'maintenance/patches/linux-modern.patch';p.write_text(''.join(output));print(p, p.stat().st_size)
