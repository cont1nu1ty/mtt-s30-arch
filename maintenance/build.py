#!/usr/bin/env python3
"""Prepare and build in a new directory; never installs/loads kernel modules."""
import argparse,json,pathlib,subprocess,hashlib,re
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--deb',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--kernel-build',type=pathlib.Path,required=True);p.add_argument('--jobs',type=int,default=4);a=p.parse_args()
a.output=a.output.resolve();k=a.kernel_build.resolve()
if a.output.exists():p.error('output already exists; choose a new directory')
if a.jobs<1:p.error('jobs must be positive')
release=(k/'include/config/kernel.release').read_text().strip()
subprocess.run(['python3',str(HERE/'prepare.py'),'--deb',str(a.deb.resolve()),'--output',str(a.output/'source')],check=True)
with (a.output/'build.log').open('w') as log:
 r=subprocess.run(['make',f'-j{a.jobs}','ARCH=x86_64',f'KERNELVER={release}',f'KERNELDIR={k}'],cwd=a.output/'source',stdout=log,stderr=subprocess.STDOUT)
text=(a.output/'build.log').read_text();mod=a.output/'source/mtgpu.ko'
report={'kernel':release,'build_exit':r.returncode,'module_built':r.returncode==0 and mod.exists(),'runtime_tested':False,'objtool_warnings':text.count('warning: objtool:'),'vendor_blob_modified':hashlib.sha256((a.output/'source/objs/x86_64/mtgpu_core.o_binary').read_bytes()).hexdigest() != 'd0fdaceab37bce7387d376f8a87a2e9dbf210eeccf4f4f7c67f8dee83f4e8200'}
if report['module_built']:
 report['module_sha256']=hashlib.sha256(mod.read_bytes()).hexdigest()
 report['vermagic']=subprocess.check_output(['modinfo','-F','vermagic',str(mod)],text=True).strip()
 report['s30_pci_alias_present']='pci:v00001ED5d00000102' in subprocess.check_output(['modinfo','-F','alias',str(mod)],text=True)
(a.output/'result.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2));raise SystemExit(r.returncode)
