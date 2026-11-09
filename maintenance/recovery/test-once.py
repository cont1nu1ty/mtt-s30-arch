#!/usr/bin/env python3
"""One-shot, root-staged GPU initialization test. Never installs a driver.
start: verify backup, stage files and launch a transient system service.
worker: calibrate/arm hardware watchdog, supervise child, then reboot.
probe: stop desktop and run bounded initialization checks with private libraries.
"""
import array,fcntl,hashlib,json,os,pathlib,re,shutil,signal,stat,struct,subprocess,sys,tempfile,time
import workload_support
import desktop_support
import session_process
KERNEL='7.2.14-arch1-1'
MODULE_SHA='6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff'
WORKLOAD_MANIFEST_SHA='68c2d8c057dae856de6f5baad1771125fd2310647b02098ad92b1586e5766ea8'
# Historical artifacts are accepted only for post-reboot evidence collection.
REVIEWED_MODULES={MODULE_SHA,'db8e4393ec50e0e2542dafdb7277240627406b847dc19d0427444712249143bb','824b81aa1a2cae0714bf670b78cf0a29ceaac87f6ac395281a3acb44fb530a0c','39290bf0fee97d8dfbce41959b9869efb5b10dc0f7dd3c495568b92b1d721558'}
DEB_SHA='04c286ba452fe0cfbea2c47465f0c48b0659c09b896f05f363feba680dd8efda'
# Verified against this host's linux/watchdog.h; x86_64 Linux ioctl ABI.
GETSUPPORT,SETOPTIONS,KEEPALIVE,SETTIMEOUT,GETTIMEOUT=2150127360,2147768068,2147768069,3221509894,2147768071
GETTIMELEFT=2147768074
MAGICCLOSE,ALARMONLY,DISABLE=0x100,0x400,1
DURATION,DELAY=180,30
WATCH=pathlib.Path('/sys/class/watchdog/watchdog0')
GPU=pathlib.Path('/sys/bus/pci/devices/0000:04:00.0')
ENV={**os.environ,'LC_ALL':'C','SYSTEMD_COLORS':'0','PATH':'/usr/bin:/usr/sbin'}

def sha(p):
 h=hashlib.sha256()
 with pathlib.Path(p).open('rb') as f:
  for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
 return h.hexdigest()

def save(path,data):
 path=pathlib.Path(path)
 fd,name=tempfile.mkstemp(prefix=path.name+'.',dir=path.parent);tmp=pathlib.Path(name)
 try:
  # The service uses UMask=0077. Its public summary must remain readable.
  os.fchmod(fd,0o644)
  with os.fdopen(fd,'w') as f:
   json.dump(data,f,ensure_ascii=False,indent=2);f.write('\n');f.flush();os.fsync(f.fileno())
  os.replace(tmp,path)
  directory=os.open(path.parent,os.O_RDONLY|os.O_DIRECTORY)
  try:os.fsync(directory)
  finally:os.close(directory)
 finally:
  tmp.unlink(missing_ok=True)

def check(condition,message):
 if not condition:raise RuntimeError(message)

def expected_module_sha(report,post_reboot=False):
 expected=report.get('module_sha256')
 check(expected in (REVIEWED_MODULES if post_reboot else {MODULE_SHA}),'Unreviewed or superseded module for this operation.')
 return expected

def integer_ioctl(fd,request,value=0):
 a=array.array('i',[value]);fcntl.ioctl(fd,request,a,True);return a[0]

def output(args,timeout=30):
 return subprocess.check_output(args,text=True,env=ENV,timeout=timeout).strip()

def check_boot_entries(entries,expected):
 selected=[e for e in entries if e.get('isSelected')]
 default=[e for e in entries if e.get('isDefault')]
 check(len(selected)==1 and selected[0].get('id')==expected,'Current boot entry changed.')
 check(len(default)==1 and default[0].get('id')==expected,'Next default is not the known working boot entry.')
 check(selected[0].get('type')=='type1','Only the reviewed Type #1 entry is supported.')

def check_efi_overrides():
 efi=pathlib.Path('/sys/firmware/efi/efivars')
 # Refuse pending firmware/boot-loader overrides rather than changing them.
 for pattern in ('BootNext-*','LoaderEntryOneShot-*'):
  for path in efi.glob(pattern):
   data=path.read_bytes()[4:]
   check(not data or not any(data),'Pending EFI override: '+path.name)
 for path in efi.glob('OsIndications-*'):
  check(not int.from_bytes(path.read_bytes()[4:],'little')&1,'Boot into firmware setup is pending.')

def compare_esp(expected,live):
 return {'expected_files':len(expected),'current_files':len(live),
         'added':sorted(live.keys()-expected.keys()),
         'removed':sorted(expected.keys()-live.keys()),
         'changed':sorted(p for p in expected.keys()&live.keys() if expected[p]!=live[p]),
         'unchanged_files':sum(expected[p]==live[p] for p in expected.keys()&live.keys())}

def check_esp_difference(difference,post_reboot=False):
 changed=set(difference['changed'])
 # Only the post-reboot collector may classify the documented seed rotation.
 # Pre-load verification remains strict; missing/new files always require review.
 allowed={'loader/random-seed'} if post_reboot else set()
 check(not difference['added'] and not difference['removed'] and changed<=allowed,
       'ESP changed outside the allowed comparison scope: '+json.dumps(difference))

def verify_backup(backup,post_reboot=False):
 check(os.geteuid()==0,'Run with sudo in your terminal.')
 check(backup.parent==pathlib.Path('/var/lib/mtt-s30-test'),'Unexpected backup directory.')
 check(backup.stat().st_uid==0 and not backup.stat().st_mode&0o022,'Backup permissions are unsafe.')
 check(not backup.parent.is_symlink() and backup.parent.stat().st_uid==0 and not backup.parent.stat().st_mode&0o022,'Recovery base permissions are unsafe.')
 for name in ('report.json','efi-sha256.json','efi-before.tar','mtgpu.ko','vendor.deb'):
  p=backup/name;s=p.lstat()
  check(stat.S_ISREG(s.st_mode) and s.st_uid==0 and not s.st_mode&0o022,'Unsafe staged file: '+name)
 report=json.loads((backup/'report.json').read_text())
 check(os.uname().release==KERNEL,'Kernel changed; stop and rebuild.')
 check(sha(backup/'efi-before.tar')==report['backup_sha256'],'EFI backup checksum changed.')
 expected=json.loads((backup/'efi-sha256.json').read_text());esp=pathlib.Path(report['esp'])
 live={str(p.relative_to(esp)):sha(p) for p in sorted(esp.rglob('*')) if p.is_file()}
 difference=compare_esp(expected,live)
 check_esp_difference(difference,post_reboot)
 report['esp_comparison']=difference
 check_efi_overrides()
 entries=json.loads(output(['bootctl','list','--json=short','--no-pager']))
 check_boot_entries(entries,report['entry'])
 check(output(['findmnt','-n','-o','SOURCE','--mountpoint',str(esp)])==report['esp_source'],'ESP device changed.')
 check(sha(backup/'mtgpu.ko')==expected_module_sha(report,post_reboot),'Module checksum changed.')
 check(sha(backup/'vendor.deb')==DEB_SHA,'Vendor archive checksum changed.')
 check(output(['modinfo','-F','vermagic',str(backup/'mtgpu.ko')]).startswith(KERNEL+' '),'Module vermagic mismatch.')
 check((GPU/'vendor').read_text().strip()=='0x1ed5' and (GPU/'device').read_text().strip()=='0x0102','Target PCI device changed.')
 check(not (GPU/'driver').exists(),'Target PCI device already has a driver.')
 check(not pathlib.Path('/sys/module/mtgpu').exists(),'mtgpu is already loaded.')
 r=subprocess.run(['modinfo','-n','mtgpu'],capture_output=True)
 check(r.returncode!=0,'mtgpu is already installed; automatic boot behavior requires review.')
 check((WATCH/'state').read_text().strip()=='inactive','Hardware watchdog is already in use.')
 check((WATCH/'nowayout').read_text().strip()=='0','Watchdog cannot be safely disarmed.')
 check((WATCH/'identity').read_text().strip()=='SP5100 TCO timer','Unexpected watchdog device.')
 check(output(['systemctl','show','-p','RuntimeWatchdogUSec','--value'])=='0','PID 1 already owns the runtime watchdog.')
 check(pathlib.Path('/sys/module/firmware_class/parameters/path').read_text().strip()==report['firmware_path_before'],'Firmware path changed since preflight.')
 check('ibt' not in pathlib.Path('/proc/cpuinfo').read_text().split(),'IBT-capable host needs separate binary compatibility review.')
 return report

def audit(backup):
 report=verify_backup(backup)
 # Listing only: do not unpack or alter the initramfs.
 for image in report['boot_images']:
  if pathlib.Path(image).name.startswith('initrd'):
   listing=output(['lsinitrd',str(pathlib.Path(report['esp'])/image)],120)
   check(not re.search(r'\bmtgpu\.ko(?:\.(?:zst|xz|gz))?\b',listing),'mtgpu is already in the boot initramfs.')
 result={**report,'phase':'takeover_audit_passed','audit_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'script_sha256':sha(__file__),'watchdog_opened':False,'hardware_reset_verified':False,'desktop_changed':False}
 summary=pathlib.Path('/var/tmp')/('mtt-s30-audit-'+backup.name+'.json')
 save(summary,result)
 print('Read-only recovery audit passed; no watchdog opened, no desktop stopped, no driver loaded.')
 print('Summary:',summary)

def start(backup,workloads=False,desktop=False):
 audit(backup);report=verify_backup(backup)
 if desktop:desktop_support.verify_host()
 profile=desktop_support.PROFILE if desktop else workload_support.PROFILE if workloads else 'initialization'
 for name in ('bsdtar','systemd-run','systemctl','dmesg','pgrep','fuser','mount','findmnt','modprobe','insmod','vulkaninfo','vainfo'):
  check(shutil.which(name,path=ENV['PATH']) is not None,'Required program missing: '+name)
 stage=backup/'test';stage.mkdir(mode=0o700)
 shutil.copyfile(__file__,stage/'test-once.py')
 shutil.copyfile(pathlib.Path(__file__).with_name('workload_support.py'),stage/'workload_support.py')
 shutil.copyfile(pathlib.Path(__file__).with_name('desktop_support.py'),stage/'desktop_support.py')
 shutil.copyfile(pathlib.Path(__file__).with_name('session_process.py'),stage/'session_process.py')
 if workloads or desktop:
  source=pathlib.Path(__file__).resolve().parents[2]/'builds/workloads-20261030'
  workload_support.stage_bundle(source,stage/'workloads',WORKLOAD_MANIFEST_SHA)
  shutil.copyfile(stage/'workloads/manifest.json',stage/'workload-manifest.json')
 if desktop:
  source=pathlib.Path(__file__).resolve().parents[2]/'builds'/desktop_support.BUNDLE_DIRECTORY
  desktop_support.stage_bundle(source,stage/'desktop')
  shutil.copyfile(stage/'desktop/manifest.json',stage/'desktop-manifest.json')
 vendor=stage/'vendor';vendor.mkdir()
 with (stage/'data.tar.xz').open('wb') as f:
  subprocess.run(['bsdtar','-xOf',str(backup/'vendor.deb'),'data.tar.xz'],stdout=f,check=True)
 subprocess.run(['bsdtar','-xf',str(stage/'data.tar.xz'),'-C',str(vendor),'./lib/firmware','./usr/lib/x86_64-linux-gnu','./usr/bin/mthreads-gmi','./etc/vulkan/icd.d','./usr/share/glvnd/egl_vendor.d'],check=True)
 if desktop:desktop_support.verify_runtime_dependencies(stage)
 summary=pathlib.Path('/var/tmp')/('mtt-s30-test-'+backup.name+'.json')
 fd=os.open(summary,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o644);os.close(fd)
 save(stage/'config.json',{'summary':str(summary),'firmware_before':report['firmware_path_before'],'script_sha256':sha(stage/'test-once.py'),'workload_support_sha256':sha(stage/'workload_support.py'),'desktop_support_sha256':sha(stage/'desktop_support.py'),'session_process_sha256':sha(stage/'session_process.py'),'profile':profile,'workload_manifest_sha256':WORKLOAD_MANIFEST_SHA if workloads or desktop else None,'desktop_manifest_sha256':desktop_support.MANIFEST_SHA if desktop else None})
 save(summary,{'phase':'staged','profile':profile,'logs':str(stage),'driver_installed':False,'reboot_planned':False})
 subprocess.run(['systemd-run','--unit=mtt-s30-once','--service-type=exec','--property=TimeoutStopSec=10s','--property=KillMode=control-group','--property=OOMScoreAdjust=-900','--property=UMask=0077','--setenv=LC_ALL=C','--setenv=PATH=/usr/bin:/usr/sbin','/usr/bin/python3',str(stage/'test-once.py'),'worker',str(backup)],check=True)
 print('Test service started. If watchdog validation passes, the desktop will stop in about 30 seconds.')
 print('A normal reboot is requested about 3 minutes after arming. No boot configuration is changed.')
 print('After reboot:',summary)

def disarm(fd):
 # Explicit disable plus magic close. No driver test has started at calibration.
 integer_ioctl(fd,SETOPTIONS,DISABLE)
 os.write(fd,b'V');os.close(fd)
 check((WATCH/'state').read_text().strip()=='inactive','Watchdog disable did not take effect.')

def arm():
 fd=os.open('/dev/watchdog0',os.O_WRONLY|os.O_CLOEXEC)
 try:
  info=bytearray(40);fcntl.ioctl(fd,GETSUPPORT,info,True)
  options,version,identity=struct.unpack('II32s',info)
  check(options&MAGICCLOSE and not options&ALARMONLY,'Watchdog lacks reviewed reset/magic-close capability.')
  timeout=integer_ioctl(fd,SETTIMEOUT,60)
  check(30<=timeout<=120,'Unexpected watchdog timeout.')
  check(integer_ioctl(fd,GETTIMEOUT)==timeout,'Watchdog timeout readback mismatch.')
  integer_ioctl(fd,KEEPALIVE)
  return fd,timeout,identity.rstrip(b'\0').decode(errors='replace')
 except BaseException:
  try:disarm(fd)
  except Exception:
   # Opening a watchdog can arm it: if disable fails, request a safe reboot.
   subprocess.Popen(['systemctl','reboot'])
  raise

def calibrate_watchdog():
 old_timeout=int((WATCH/'timeout').read_text())
 fd,timeout,identity=arm()
 try:
  first=integer_ioctl(fd,GETTIMELEFT)
  check(20<first<=timeout,'Invalid watchdog remaining time.')
  time.sleep(3)
  second=integer_ioctl(fd,GETTIMELEFT)
  check(0<second<first,'Hardware watchdog counter is not decreasing.')
  integer_ioctl(fd,KEEPALIVE)
  refreshed=integer_ioctl(fd,GETTIMELEFT)
  check(second<refreshed<=timeout,'Watchdog keepalive did not refresh the counter.')
  return {'identity':identity,'first':first,'after_3s':second,'after_ping':refreshed,'hardware_reset_verified':False}
 finally:
  try:integer_ioctl(fd,SETTIMEOUT,old_timeout)
  finally:disarm(fd)

def request_reboot():
 # No blocking sync/wait here: the GPU or storage path may be stuck.
 subprocess.Popen(['systemctl','--no-block','reboot'],env=ENV)

def worker(backup):
 check(subprocess.check_output(['systemctl','show','mtt-s30-once.service','-p','MainPID','--value'],text=True).strip()==str(os.getpid()),'Worker must run as the transient system service.')
 stage=backup/'test';cfg=json.loads((stage/'config.json').read_text());summary=pathlib.Path(cfg['summary'])
 state={'phase':'watchdog_preflight','logs':str(stage),'driver_installed':False,'reboot_planned':False,'supervisor_pid':os.getpid(),'boot_id':pathlib.Path('/proc/sys/kernel/random/boot_id').read_text().strip(),'hardware_reset_verified':False}
 state['profile']=cfg.get('profile','initialization')
 fd=None;armed=False;kernel_log=None;child=None
 def publish():
  if (stage/'probe-result.json').exists():
   try:state['probe']=json.loads((stage/'probe-result.json').read_text())
   except (OSError,ValueError):pass
  save(summary,state);save(stage/'supervisor-result.json',state)
 def stop_signal(signum,frame):
  signal.signal(signal.SIGTERM,signal.SIG_IGN);signal.signal(signal.SIGINT,signal.SIG_IGN)
  if state['phase']!='reboot_requested':
   request_reboot()
   state['phase']='interrupted_reboot_required'
  publish()
  # Stop pinging; never silently disarm after device initialization began.
  while True:time.sleep(60)
 try:
  check(sha(stage/'workload_support.py')==cfg['workload_support_sha256'],'Staged workload support changed.')
  check(sha(stage/'desktop_support.py')==cfg['desktop_support_sha256'],'Staged desktop support changed.')
  check(sha(stage/'session_process.py')==cfg['session_process_sha256'],'Staged session process helper changed.')
  if cfg.get('profile') in (workload_support.PROFILE,desktop_support.PROFILE):
   check(cfg.get('workload_manifest_sha256')==WORKLOAD_MANIFEST_SHA,'Unexpected workload manifest.')
   workload_support.verify_bundle(stage/'workloads',WORKLOAD_MANIFEST_SHA)
  if cfg.get('profile')==desktop_support.PROFILE:
   check(cfg.get('desktop_manifest_sha256')==desktop_support.MANIFEST_SHA,'Unexpected desktop manifest.')
   desktop_support.verify_host();desktop_support.verify_bundle(stage/'desktop')
  verify_backup(backup);publish()
  state['watchdog_calibration']=calibrate_watchdog();publish()
  fd,timeout,identity=arm();armed=True
  state.update(phase='armed_waiting',watchdog=identity,watchdog_timeout=timeout,reboot_planned=True)
  signal.signal(signal.SIGTERM,stop_signal);signal.signal(signal.SIGINT,stop_signal)
  subprocess.run(['systemd-run','--unit=mtt-s30-deadline','--on-active=210s','--timer-property=AccuracySec=1s','/usr/bin/systemctl','--no-block','reboot'],check=True,timeout=15,env=ENV)
  begin=time.monotonic();deadline=begin+DURATION
  state['start_utc']=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime());publish()
  with (stage/'kernel-live.log').open('w') as log:
   kernel_log=subprocess.Popen(['dmesg','--follow-new','--time-format=iso'],stdout=log,stderr=subprocess.STDOUT)
  while time.monotonic()<deadline:
   integer_ioctl(fd,KEEPALIVE)
   if child is None and time.monotonic()-begin>=DELAY:
    state['phase']='testing';publish()
    with (stage/'probe.log').open('w') as log:
     child=subprocess.Popen(['/usr/bin/python3',str(stage/'test-once.py'),'probe',str(backup)],stdout=log,stderr=subprocess.STDOUT)
    state['phase']='testing';publish()
   if child is not None and child.poll() is not None:
    state['phase']='test_finished_waiting_for_reboot';state['probe_exit']=child.returncode;publish()
   time.sleep(5)
  state['phase']='reboot_requested';publish()
  request_reboot()
  # Let the watchdog expire if normal reboot does not finish. Do not magic-close.
  while True:time.sleep(60)
 except BaseException as e:
  state['error']=str(e);state['phase']='supervisor_error';publish()
  if armed or (WATCH/'state').read_text().strip()=='active':
   request_reboot()
   while True:time.sleep(60)
  else:
   state['reboot_planned']=False;publish()
   raise

def desktop_snapshot():
 active=output(['systemctl','show','display-manager','-p','ActiveState','--value'],timeout=5)
 r=subprocess.run(['pgrep','-l','-x','kwin_wayland|kwin_x11|Xorg|Xwayland|weston|sway'],capture_output=True,text=True,env=ENV,timeout=5)
 check(r.returncode in (0,1) and not r.stderr.strip(),'pgrep failed: '+r.stderr.strip())
 processes=r.stdout.strip().splitlines()
 check((r.returncode==0)==bool(processes),'Inconsistent pgrep result.')
 nodes=sorted(pathlib.Path('/dev/dri').glob('card*'))+sorted(pathlib.Path('/dev/dri').glob('renderD*'))
 check(bool(nodes),'No baseline DRM device found.')
 r=subprocess.run(['fuser',*[str(p) for p in nodes]],capture_output=True,text=True,env=ENV,timeout=5)
 check(r.returncode in (0,1),'fuser failed: '+r.stderr.strip())
 if r.returncode==1:
  check(not r.stdout.strip() and not r.stderr.strip(),'DRM users could not be checked: '+r.stderr.strip())
 return {'display_manager':active,'graphical_processes':processes,
         'drm_users':r.stdout.strip(),'drm_diagnostics':r.stderr.strip(),
         'settled':active in ('inactive','failed') and not processes and r.returncode==1}

def ensure_desktop_stopped(timeout=20,report=None):
 begin=time.monotonic();clear_samples=0
 while True:
  try:snapshot=desktop_snapshot()
  except Exception as e:
   if report:report({'elapsed_seconds':round(time.monotonic()-begin,3),'inspection_error':str(e)})
   raise
  snapshot['elapsed_seconds']=round(time.monotonic()-begin,3)
  if report:report(snapshot)
  clear_samples=clear_samples+1 if snapshot['settled'] else 0
  # SDDM can stop before the user's KWin service has completed shutdown.
  # Wait for two clean observations, preserving the original no-users gate.
  if clear_samples>=2:return
  check(time.monotonic()-begin<timeout,'Desktop/DRM did not become idle within '+str(timeout)+'s: '+json.dumps(snapshot))
  time.sleep(min(1,max(0,timeout-(time.monotonic()-begin))))

def validate_vulkan(text):
 check(not re.search(r'llvmpipe|softpipe|lavapipe|PHYSICAL_DEVICE_TYPE_CPU',text,re.I),'Vulkan selected software rendering.')
 check(re.search(r'vendorID\s*=\s*0x1ed5\b',text,re.I) and re.search(r'deviceID\s*=\s*0x0?102\b',text,re.I),'Vulkan did not report the S30 PCI identity.')

def kernel_faults(text):
 return [line for line in text.splitlines() if re.search(r'\bBUG:|\bOops:|\bWARNING:|kernel panic|general protection fault|soft lockup|hard LOCKUP|IO_PAGE_FAULT|DMAR:.*fault|IOMMU.*fault|GPU.*(?:hang|reset)|firmware.*(?:failed|error|mismatch)|resource sanity check:|mapping multiple BARs|DISPC-\d+:.*timed out|VPU register layout rejected|Failed to bind other components',line,re.I)]

def probe(backup):
 stage=backup/'test';vendor=stage/'vendor';cfg=json.loads((stage/'config.json').read_text())
 supervisor=json.loads((stage/'supervisor-result.json').read_text())
 check(supervisor.get('supervisor_pid')==os.getppid() and supervisor.get('phase')=='testing','Probe must be a child of the armed supervisor.')
 check((WATCH/'state').read_text().strip()=='active','No active watchdog; refusing device test.')
 result={'phase':'starting','checks':{},'desktop_started':False,'module_load_attempted':False}
 result['profile']=cfg.get('profile','initialization')
 def record():save(stage/'probe-result.json',result)
 def command(name,args,timeout=20,env=None):
  result['active_check']=name;record()
  begin=time.monotonic()
  try:
   with (stage/(name+'.log')).open('w') as log:
    run=session_process.run_session if name=='kwin-session' else subprocess.run
    r=run(args,stdout=log,stderr=subprocess.STDOUT,timeout=timeout,env=env)
  except subprocess.TimeoutExpired:
   result.setdefault('command_timeouts',[]).append(name);record();raise
  finally:
   result.setdefault('command_seconds',{})[name]=round(time.monotonic()-begin,3);record()
  result['checks'][name]=r.returncode;record();return r.returncode
 firmware=pathlib.Path('/sys/module/firmware_class/parameters/path')
 try:
  record();os.sync()
  check(result['profile'] in ('initialization',workload_support.PROFILE,desktop_support.PROFILE),'Unknown test profile.')
  if result['profile'] in (workload_support.PROFILE,desktop_support.PROFILE):
   result['active_check']='workload-artifact-check';record()
   workload_support.verify_bundle(stage/'workloads',WORKLOAD_MANIFEST_SHA)
  if result['profile']==desktop_support.PROFILE:
   result['active_check']='desktop-artifact-check';record()
   desktop_support.verify_host();desktop_support.verify_bundle(stage/'desktop')
  check(command('stop-desktop',['systemctl','stop','display-manager'],25)==0,'Cannot stop display manager.')
  def desktop_progress(snapshot):
   result.setdefault('desktop_shutdown_observations',[]).append(snapshot);record()
  result['active_check']='desktop-idle';record()
  ensure_desktop_stopped(report=desktop_progress)
  check(command('protect-esp',['mount','-o','remount,ro','/efi'])==0,'Cannot protect ESP read-only; no driver load attempted.')
  options=subprocess.check_output(['findmnt','-n','-o','OPTIONS','--mountpoint','/efi'],text=True).strip().split(',')
  check('ro' in options,'ESP did not become read-only.')
  result['esp_read_only']=True;record()
  check(command('kernel-before',['dmesg','--time-format=raw'])==0,'Cannot read baseline kernel log.')
  firmware.write_text(str(vendor/'lib/firmware'))
  check(command('dependencies',['modprobe','-a','drm_display_helper','snd','snd-pcm'])==0,'Cannot load kernel dependencies.')
  result['phase']='loading_module';result['module_load_attempted']=True;record()
  check(command('insmod',['insmod',str(backup/'mtgpu.ko'),'mtgpu_drm_major=2'],30)==0,'Module initialization failed.')
  result['active_check']='device-binding';record()
  gpu=GPU
  result['bound_driver']=(gpu/'driver').resolve().name
  result['render_nodes']=[p.name for p in (gpu/'drm').glob('renderD*')]
  check(result['bound_driver']=='mtgpu' and result['render_nodes'],'S30 has no mtgpu render node.')
  check(command('iomem-after',['cat','/proc/iomem'])==0,'Cannot capture memory resource ownership.')
  check(command('pci-resources',['cat',str(gpu/'resource')])==0,'Cannot capture S30 BAR ranges.')
  def check_kernel():
   check(command('kernel-check',['dmesg','--time-format=raw'])==0,'Cannot read kernel log after GPU operation.')
   before=(stage/'kernel-before.log').read_text().splitlines()
   after=(stage/'kernel-check.log').read_text().splitlines()
   # dmesg output can rotate; fail closed if the boundary was lost.
   if before:
    check(before[-1] in after,'Kernel log boundary lost; manual inspection required.')
    after=after[after.index(before[-1])+1:]
   result['kernel_faults']=kernel_faults('\n'.join(after));record()
   check(not result['kernel_faults'],'Kernel fault detected; skipping further GPU calls.')
  check_kernel()
  env={**os.environ,'LD_LIBRARY_PATH':str(vendor/'usr/lib/x86_64-linux-gnu'),'VK_DRIVER_FILES':str(vendor/'etc/vulkan/icd.d/musaicdconf.json'),'LIBVA_DRIVERS_PATH':str(vendor/'usr/lib/x86_64-linux-gnu/dri'),'LIBVA_DRIVER_NAME':'mtgpu'}
  for key in list(env):
   if key.startswith('VK_') and key!='VK_DRIVER_FILES' or key in ('DISPLAY','WAYLAND_DISPLAY','LD_PRELOAD','LD_AUDIT'):env.pop(key,None)
  env['LC_ALL']='C';env['VK_LOADER_LAYERS_DISABLE']='~all~'
  for name,key in (('runtime','XDG_RUNTIME_DIR'),('cache','XDG_CACHE_HOME')):
   path=stage/name;path.mkdir(mode=0o700,exist_ok=True);env[key]=str(path)
  check(command('mthreads-gmi',[str(vendor/'usr/bin/mthreads-gmi')],20,env)==0,'Management interface failed.')
  check_kernel()
  check(command('vulkan',['vulkaninfo','--summary'],25,env)==0,'Vulkan enumeration failed.')
  validate_vulkan((stage/'vulkan.log').read_text());check_kernel()
  check(command('vaapi',['vainfo','--display','drm','--device','/dev/dri/'+result['render_nodes'][0]],25,env)==0,'VA-API enumeration failed.')
  check_kernel()
  if result['profile'] in (workload_support.PROFILE,desktop_support.PROFILE):
   result['workloads']=workload_support.run_workloads(stage,'/dev/dri/'+result['render_nodes'][0],env,command,check_kernel,WORKLOAD_MANIFEST_SHA)
   result['phase']='workload_checks_passed'
   if result['profile']==desktop_support.PROFILE:
    cards=[p.name for p in (gpu/'drm').glob('card[0-9]*') if re.fullmatch(r'card\d+',p.name)]
    check(len(cards)==1,'Expected exactly one S30 KMS card node.')
    result['kms_node']='/dev/dri/'+cards[0];record()
    result['desktop']=desktop_support.run_desktop(stage,'/dev/dri/'+result['render_nodes'][0],result['kms_node'],env,command,check_kernel)
    result['phase']='desktop_checks_passed'
  else:
   check(result['profile']=='initialization','Unknown test profile.')
   result['phase']='initialization_checks_passed'
  result['passed']=True;record()
 except Exception as e:
  result.update(phase='failed',passed=False,error=str(e),failed_check=result.get('active_check'));record()
 finally:
  result['driver_loaded']=pathlib.Path('/sys/module/mtgpu').exists()
  if (stage/'desktop-session-result.json').exists():
   try:
    desktop=json.loads((stage/'desktop-session-result.json').read_text())
    result['desktop_started']=desktop.get('kwin_started',False)
    result['desktop_session']=desktop
   except (OSError,ValueError) as e:result.update(desktop_result_error=str(e),passed=False,phase='failed')
  try:firmware.write_text(cfg['firmware_before']+'\n')
  except OSError as e:result.update(firmware_restore_error=str(e),passed=False,phase='failed')
  try:
   check(command('kernel-final',['dmesg','--time-format=iso'],10)==0,'Final kernel log capture failed.')
  except Exception as e:result.update(final_log_error=str(e),passed=False,phase='failed')
  finally:record()
 return 0 if result.get('passed') else 1

if __name__=='__main__':
 try:
  check(len(sys.argv)==3 and sys.argv[1] in ('audit','start','worker','probe'),'Usage: sudo python3 test-once.py audit|start /var/lib/mtt-s30-test/TIMESTAMP')
  check(os.geteuid()==0,'Root required.')
  backup=pathlib.Path(sys.argv[2]).resolve()
  sys.exit({'audit':audit,'start':start,'worker':worker,'probe':probe}[sys.argv[1]](backup) or 0)
 except Exception as e:
  print('STOP: '+str(e),file=sys.stderr);sys.exit(1)
