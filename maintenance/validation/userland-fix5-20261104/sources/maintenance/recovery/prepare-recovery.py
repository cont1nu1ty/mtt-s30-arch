#!/usr/bin/env python3
"""Root-only READ/COPY preflight. Never loads a module or changes boot settings."""
import hashlib,json,os,pathlib,re,shlex,shutil,subprocess,sys,tarfile,time
ROOT=pathlib.Path(__file__).resolve().parents[2]
KERNEL='7.2.14-arch1-1'
MODULE_SHA='6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff'
DEB_SHA='04c286ba452fe0cfbea2c47465f0c48b0659c09b896f05f363feba680dd8efda'

def digest(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()

def run(*args):
 return subprocess.check_output(args,text=True,env={**os.environ,'LC_ALL':'C','SYSTEMD_COLORS':'0'}).strip()

def fail(msg):raise RuntimeError(msg)

def entry_images(esp,entry):
 referenced=[]
 for line in entry.read_text().splitlines():
  fields=shlex.split(line,comments=True)
  if fields and fields[0] in ('linux','efi','initrd'):
   if len(fields)!=2:fail('Unexpected boot image reference.')
   p=(esp/fields[1].lstrip('/')).resolve()
   if not p.is_relative_to(esp) or not p.is_file():fail('A current-entry boot image is missing or outside the ESP.')
   referenced.append(p)
 if not referenced:fail('No kernel/UKI references found in current entry.')
 return referenced

def main():
 if os.geteuid()!=0:fail('Run with sudo in your own terminal. Do not send your password to the chat.')
 if os.uname().release!=KERNEL:fail('Running kernel changed; rebuild/review before testing.')
 if pathlib.Path('/sys/module/mtgpu').exists():fail('mtgpu is already loaded; this workflow assumes the original framebuffer state.')
 installed=subprocess.run(['modinfo','-n','mtgpu'],capture_output=True,text=True)
 if installed.returncode==0:fail('An mtgpu module is already installed in the system; inspect its autoload behavior first.')
 esp=pathlib.Path(run('bootctl','--print-esp-path')).resolve()
 if esp!=pathlib.Path('/efi'):fail('Unexpected ESP location; review before proceeding.')
 mount=json.loads(run('findmnt','--json','--mountpoint',str(esp),'-o','TARGET,SOURCE,FSTYPE'))['filesystems'][0]
 status=run('bootctl','status','--no-pager')
 if 'systemd-boot' not in status:fail('Unexpected boot loader.')
 match=re.search(r'^\s*Current Entry:\s*(\S+)\s*$',status,re.M)
 if not match:fail('Cannot determine the current boot entry.')
 entry_id=match.group(1)
 if pathlib.Path(entry_id).name!=entry_id:fail('Invalid boot entry id.')
 entry=esp/'loader/entries'/entry_id
 if not entry.is_file():fail('Current Type #1 entry is missing; manual UKI/entry review required.')
 referenced=entry_images(esp,entry)
 module=ROOT/'builds/runtime-fix3-v2-7.2.14-20261103/source/mtgpu.ko'
 deb=ROOT/'official/musa_3.1.0-pc_x86.deb'
 if digest(module)!=MODULE_SHA or digest(deb)!=DEB_SHA:fail('Reviewed driver artifact checksum changed.')
 if not run('modinfo','-F','vermagic',str(module)).startswith(KERNEL+' '):fail('Module vermagic mismatch.')
 base=pathlib.Path('/var/lib/mtt-s30-test')
 if base.is_symlink():fail('Recovery base must not be a symlink.')
 base.mkdir(mode=0o700,exist_ok=True)
 if base.stat().st_uid!=0 or base.stat().st_mode & 0o022:fail('Recovery base must be root-owned and not writable by group/others.')
 stamp=time.strftime('%Y%m%d-%H%M%S');out=base/stamp;out.mkdir(mode=0o700)
 files=sorted(p for p in esp.rglob('*') if p.is_file())
 size=sum(p.stat().st_size for p in files)
 if size>2*1024**3 or shutil.disk_usage(base).free < size*2+512*1024**2:fail('Insufficient bounded backup space; no test started.')
 before={str(p.relative_to(esp)):digest(p) for p in files}
 backup=out/'efi-before.tar'
 with tarfile.open(backup,'w') as tar:tar.add(esp,arcname='efi',recursive=True)
 # Validate the archive content against the live files, without restoring it.
 with tarfile.open(backup,'r') as tar:
  archived={}
  for member in tar:
   if member.isfile():
    f=tar.extractfile(member);h=hashlib.sha256()
    for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    archived[member.name.removeprefix('efi/')]=h.hexdigest()
 if archived!=before:fail('Backup content mismatch; no test started.')
 after={str(p.relative_to(esp)):digest(p) for p in sorted(esp.rglob('*')) if p.is_file()}
 if before!=after:fail('ESP changed during backup; pause kernel/package updates and retry.')
 # Copy reviewed artifacts to root-owned staging; do not install them.
 shutil.copyfile(module,out/'mtgpu.ko')
 shutil.copyfile(deb,out/'vendor.deb')
 if digest(out/'mtgpu.ko')!=MODULE_SHA or digest(out/'vendor.deb')!=DEB_SHA:fail('Staged artifact checksum mismatch.')
 w=pathlib.Path('/sys/class/watchdog/watchdog0')
 watchdog={name:(w/name).read_text().strip() for name in ('identity','state','timeout','nowayout') if (w/name).exists()}
 report={'phase':'backup_only_no_test_started','running_kernel':KERNEL,'boot_loader':'systemd-boot','entry':entry_id,'esp':str(esp),'esp_source':mount['source'],'backup_directory':str(out),'backup_sha256':digest(backup),'esp_file_count':len(files),'esp_unchanged':True,'boot_images':[str(p.relative_to(esp)) for p in referenced],'firmware_path_before':pathlib.Path('/sys/module/firmware_class/parameters/path').read_text().strip(),'watchdog':watchdog,'systemd_watchdog':run('systemctl','show','-p','RuntimeWatchdogUSec','-p','RebootWatchdogUSec'),'module_sha256':MODULE_SHA,'module_installed':False,'module_loaded':False}
 (out/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 (out/'efi-sha256.json').write_text(json.dumps(before,indent=2)+'\n')
 # Make ONLY this non-secret summary available to the invoking desktop user.
 uid=int(os.environ.get('SUDO_UID','0'));gid=int(os.environ.get('SUDO_GID','0'))
 summary=pathlib.Path('/var/tmp')/f'mtt-s30-preflight-{stamp}.json'
 fd=os.open(summary,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o644)
 os.fchmod(fd,0o644)
 with os.fdopen(fd,'w') as f:f.write(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 os.chown(summary,uid,gid)
 print('Preflight and EFI backup completed. No driver was loaded; desktop unchanged.')
 print('Summary:',summary)
 print('Root-owned backup:',out)
 return out

if __name__=='__main__':
 try:main()
 except (RuntimeError,OSError,subprocess.CalledProcessError,ValueError,KeyError) as e:
  print('STOP: '+str(e),file=sys.stderr);sys.exit(1)
