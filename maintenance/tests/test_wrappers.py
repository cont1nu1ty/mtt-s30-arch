#!/usr/bin/env python3
"""Compile actual OS wrappers against small ownership-tracking fake kernel APIs.
These are regression tests for wrapper contracts, not a loaded-kernel test.
"""
import os, pathlib, re, subprocess, tempfile, unittest
ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCE = pathlib.Path(os.environ.get('MTGPU_SOURCE', str(ROOT / 'work/mtgpu-3.1.0'))) / 'src/common/os-interface.c'

def function(source, name):
    match = re.search(r'^([^\n]*\b' + name + r'\([^;]*?\)\n\{)', source, re.M)
    if not match:
        raise ValueError(name)
    start = match.start(); pos = match.end(); depth = 1
    while depth:
        depth += (source[pos] == '{') - (source[pos] == '}')
        pos += 1
    return source[start:pos]

def compile_run(code):
    with tempfile.TemporaryDirectory(prefix='mtgpu-tests-') as d:
        c = pathlib.Path(d)/'test.c'; exe = pathlib.Path(d)/'test'
        c.write_text(code)
        subprocess.run(['cc', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
                        '-Wno-unused-parameter', '-fsanitize=address,undefined',
                        '-g', str(c), '-o', str(exe)], check=True)
        subprocess.run([str(exe)], check=True)

class Wrappers(unittest.TestCase):
    def test_fixed_width_copy(self):
        code = '#include <string.h>\n#include <assert.h>\n' + function(SOURCE.read_text(), 'os_strncpy')
        code += r'''
int main(void) {
 char b[8]; const char raw[3] = {'a','b','c'};
 memset(b, 0x5a, sizeof b);
 assert(os_strncpy(b, "x", 5) == b);
 assert(!memcmp(b, "x\0\0\0\0", 5) && b[5] == 0x5a);
 os_strncpy(b, raw, 3); assert(!memcmp(b, raw, 3));
 memset(b, 0x5a, sizeof b); os_strncpy(b, raw, 0); assert(b[0] == 0x5a);
 os_strncpy(b, "", 8); for (int i=0;i<8;i++) assert(b[i] == 0);
 return 0;
}
'''
        compile_run(code)

    def test_mkdir_five_argument_lifecycle(self):
        self.check_mkdir_lifecycle(True)

    def test_mkdir_four_argument_lifecycle(self):
        self.check_mkdir_lifecycle(False)

    def check_mkdir_lifecycle(self, five_args):
        source = SOURCE.read_text()
        code = r'''
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <assert.h>
#define MT_VFS_MKDIR_RETURNS_DENTRY
#define OS_VFS_MKDIR_RETURNS_DENTRY
#define container_of(p,t,m) ((t *)((char *)(p)-offsetof(t,m)))
#define PTR_ERR_OR_ZERO(p) ((intptr_t)(p)<0 ? (int)(intptr_t)(p) : 0)
typedef unsigned short umode_t;
struct inode {int dummy;};
struct dentry {int id;};
struct path {struct dentry *dentry; void *mnt;};
static struct dentry original={1}, replacement={2}, parent={3};
static struct inode inode;
static int outcome, locks, drops;
static struct dentry *ended;
static void *os_kzalloc(size_t n) {return calloc(1,n);}
static void *mnt_idmap(void *mnt) {return mnt;}
static struct inode *d_inode(struct dentry *d) {return &inode;}
static struct dentry *start_creating_path(int fd,const char *name,struct path *p,unsigned flags) {
 p->dentry=&parent; locks++; return &original;
}
static struct dentry *vfs_mkdir(void *id,struct inode *i,struct dentry *d,umode_t mode
#ifdef OS_VFS_MKDIR_RETURNS_DENTRY
 ,void *di
#endif
) {
 if(outcome<0) {locks--; drops++; return (void *)(intptr_t)outcome;}
 if(outcome==1) {drops++; return &replacement;}
 return d;
}
static void end_creating_path(struct path *p,struct dentry *d) {
 ended=d; if ((intptr_t)d>=0) {locks--; drops++;}
}
'''
        if not five_args:
            code = code.replace('#define OS_VFS_MKDIR_RETURNS_DENTRY', '')
        a = source.index('struct mt_os_path {'); b = source.index('\n};', a)+3
        code += source[a:b] + '\n'
        for name in ['os_path_create','os_kern_path_create','os_vfs_mkdir','os_done_path_create']:
            code += function(source, name) + '\n'
        code += r'''
int main(void) {
 struct path *p=os_path_create();
 for(int kind=-1;kind<=1;kind++) {
   outcome=kind; drops=0; ended=NULL;
   struct dentry *d=os_kern_path_create(0,"x",p,0); assert(locks==1);
   assert(os_vfs_mkdir(p,d,0755)==(kind<0?-1:0));
   os_done_path_create(p,d); assert(locks==0);
   assert(ended==(kind<0?(void *)(intptr_t)-1:kind==1?&replacement:&original));
   assert(drops==(kind==1?2:1));
 }
 /* A security-path rejection skips mkdir, including after a previous failure. */
 drops=0; struct dentry *d=os_kern_path_create(0,"x",p,0);
 os_done_path_create(p,d); assert(ended==&original && locks==0 && drops==1);
 free(p); return 0;
}
'''
        compile_run(code)

class RuntimeCompatibility(unittest.TestCase):
    def test_all_direct_workqueue_allocations_use_compatibility(self):
        # WARN_ONCE exposes only the first bad queue in each boot. Audit every
        # source call so later queues cannot hide behind an earlier warning.
        calls=[]
        for path in (SOURCE.parents[2] / 'src').rglob('*.c'):
            text=re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(), flags=re.S)
            for match in re.finditer(r'\balloc_workqueue\s*\(',text):
                pos=match.end();depth=1
                while depth:
                    depth+=(text[pos]=='(')-(text[pos]==')');pos+=1
                call=text[match.end():pos-1]
                calls.append(str(path))
                self.assertIn('mt_legacy_workqueue_flags(',call,str(path)+': '+call)
        self.assertGreaterEqual(len(calls),6)

    def test_pvr_driver_queue_uses_legacy_default_and_propagates_oom(self):
        tree=SOURCE.parents[2]
        header=(tree/'inc/workqueue_compat.h').read_text().replace('#include <linux/workqueue.h>','')
        body=function((tree/'src/pvr/module_common.c').read_text(),'PVRSRVDriverInit')
        for modern in (False,True):
            with self.subTest(modern=modern):
                code=r'''
#include <assert.h>
#include <errno.h>
#include <string.h>
#define NO_HARDWARE
#define PVR_DPF(args) ((void)0)
typedef int PVRSRV_ERROR;
enum {PVRSRV_OK=0, WQ_UNBOUND=2};
struct workqueue_struct {int dummy;};
static struct workqueue_struct queue, *mtgpu_wq;
static unsigned seen, calls;
static int fail_alloc, early_error;
static int PVROSFuncInit(void) {return early_error;}
static int PVRSRVCommonDriverInit(void) {return PVRSRV_OK;}
static int pvr_apphint_init(void) {return 0;}
static struct workqueue_struct *alloc_workqueue(const char *name,unsigned flags,int max) {
 assert(!strcmp(name,"mtgpu-wq") && max==0);seen=flags;calls++;
 return fail_alloc ? 0 : &queue;
}
'''
                if modern:code+='#define OS_ENUM_WQ_PERCPU_EXIST\nenum {WQ_PERCPU=256};\n'
                code+=header+'\n'+body+r'''
int main(void) {
 assert(PVRSRVDriverInit()==0 && mtgpu_wq==&queue && calls==1);
#ifdef OS_ENUM_WQ_PERCPU_EXIST
 assert(seen==WQ_PERCPU);
#else
 assert(seen==0);
#endif
 fail_alloc=1;assert(PVRSRVDriverInit()==-ENOMEM && mtgpu_wq==0 && calls==2);
 early_error=1;assert(PVRSRVDriverInit()==-ENOMEM && calls==2);
 return 0;
}
'''
                compile_run(code)

    def test_workqueue_legacy_default_on_modern_kernel(self):
        self.check_workqueues(True)

    def test_workqueue_old_kernel_has_no_new_flag_dependency(self):
        self.check_workqueues(False)

    def check_workqueues(self, modern):
        tree = SOURCE.parents[2]
        header = (tree / 'inc/workqueue_compat.h').read_text().replace('#include <linux/workqueue.h>', '')
        code = r'''
#include <assert.h>
typedef char IMG_CHAR;
enum {WQ_UNBOUND=2, WQ_MEM_RECLAIM=8, WQ_CPU_INTENSIVE=32};
struct workqueue_struct {int dummy;};
static struct workqueue_struct queue;
static unsigned int seen;
static int seen_max, fail_alloc;
static const char *seen_name;
static struct workqueue_struct *alloc_workqueue(const char *name, unsigned int flags, int max) {
 seen=flags; seen_max=max; seen_name=name;
 return fail_alloc ? 0 : &queue;
}
'''
        if modern:
            code += '#define OS_ENUM_WQ_PERCPU_EXIST\nenum {WQ_PERCPU=256};\n'
        code += header + '\n'
        code += function(SOURCE.read_text(), 'os_alloc_workqueue') + '\n'
        code += function((tree / 'src/pvr/osfunc.c').read_text(), 'OSAllocWorkqueue') + '\n'
        code += r'''
int main(void) {
 const char *name="mtgpu_ipc_con_workq";
 struct workqueue_struct *(*wrappers[])(const char*,unsigned int,int)={os_alloc_workqueue,OSAllocWorkqueue};
 for(unsigned int i=0;i<2;i++) {
  fail_alloc=0;
  assert(wrappers[i](name, WQ_MEM_RECLAIM|WQ_CPU_INTENSIVE, 1)==&queue);
  assert(seen_name==name && seen_max==1);
#ifdef OS_ENUM_WQ_PERCPU_EXIST
  assert(seen==(WQ_MEM_RECLAIM|WQ_CPU_INTENSIVE|WQ_PERCPU));
  wrappers[i](name,WQ_PERCPU|WQ_MEM_RECLAIM,4);
  assert(seen==(WQ_PERCPU|WQ_MEM_RECLAIM) && seen_max==4);
#else
  assert(seen==(WQ_MEM_RECLAIM|WQ_CPU_INTENSIVE));
#endif
  wrappers[i](name,WQ_UNBOUND|WQ_MEM_RECLAIM,8);
  assert(seen==(WQ_UNBOUND|WQ_MEM_RECLAIM) && seen_max==8);
  fail_alloc=1; assert(wrappers[i](name,0,1)==0);
 }
 return 0;
}
'''
        compile_run(code)

    def test_pci_handoff_precedes_probe_and_propagates_errors(self):
        self.check_pci_handoff(True)

    def test_pci_older_kernel_retains_vendor_path(self):
        self.check_pci_handoff(False)

    def check_pci_handoff(self, modern):
        source = (SOURCE.parents[2] / 'src/mtgpu/mtgpu_drv.c').read_text()
        self.assertRegex(source, r'\.probe\s*=\s*mtgpu_pci_probe\s*,')
        code = r'''
#include <assert.h>
#define KERNEL_VERSION(a,b,c) (((a)<<16)+((b)<<8)+(c))
#define DRIVER_NAME "mtgpu"
struct pci_dev {int dummy;};
struct pci_device_id {int dummy;};
static struct pci_dev device;
static struct pci_device_id id;
static int step, handoff_error, probe_error;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,13,0)
static int aperture_remove_conflicting_pci_devices(struct pci_dev *p,const char *name) {
 assert(p==&device && name[0]=='m' && step==0); step=1; return handoff_error;
}
#endif
static int mtgpu_probe(struct pci_dev *p,const struct pci_device_id *match) {
 assert(p==&device && match==&id);
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,13,0)
 assert(step==1);
#else
 assert(step==0);
#endif
 step=2; return probe_error;
}
'''
        code = '#define LINUX_VERSION_CODE ' + ('0x070200' if modern else '0x060800') + '\n' + code
        code += function(source, 'mtgpu_pci_probe') + '\n'
        code += r'''
int main(void) {
 step=0; assert(mtgpu_pci_probe(&device,&id)==0 && step==2);
 step=0; probe_error=-12; assert(mtgpu_pci_probe(&device,&id)==-12 && step==2);
 step=0; handoff_error=-16;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,13,0)
 assert(mtgpu_pci_probe(&device,&id)==-16 && step==1);
#else
 assert(mtgpu_pci_probe(&device,&id)==-12 && step==2);
#endif
 return 0;
}
'''
        compile_run(code)

class IOMMUBridge(unittest.TestCase):
    def test_bus_selection_and_reference_lifetime(self):
        header = (SOURCE.parents[2] / 'inc/iommu_compat.h').read_text()
        header = re.sub(r'^#include <linux/.*?>$', '', header, flags=re.M)
        code = r'''
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <assert.h>
#define OS_IOMMU_PAGING_DOMAIN_CALLABLE
#define IS_ERR(p) ((intptr_t)(p)<0)
#define pr_err(...) ((void)0)
struct iommu_ops {int id;};
struct iommu_domain {const struct iommu_ops *owner;};
struct device {struct iommu_domain *domain; int refs;};
struct bus_type {struct device *devices; int count;};
static bool fail_alloc;
static struct iommu_domain output;
static struct iommu_domain *iommu_get_domain_for_dev(struct device *d) {return d->domain;}
static struct device *get_device(struct device *d) {d->refs++; return d;}
static void put_device(struct device *d) {if(d) d->refs--;}
static int bus_for_each_dev(const struct bus_type *b,void *start,void *data,int (*fn)(struct device*,void*)) {
 for(int i=0;i<b->count;i++) fn(&b->devices[i],data);
 return 0;
}
static struct iommu_domain *iommu_paging_domain_alloc(struct device *d) {
 return fail_alloc?(void *)(intptr_t)-12:&output;
}
'''
        code += header
        code += r'''
int main(void) {
 struct iommu_ops a={1},b={2}; struct iommu_domain da={&a},db={&b};
 struct device devices[2]={{NULL,0},{NULL,0}};
 struct bus_type bus={devices,2};
 assert(!mt_iommu_present(&bus)); assert(!mt_iommu_domain_alloc(&bus));
 devices[0].domain=&da; assert(mt_iommu_present(&bus));
 assert(mt_iommu_domain_alloc(&bus)==&output);
 devices[1].domain=&da; assert(mt_iommu_domain_alloc(&bus)==&output);
 devices[1].domain=&db; assert(!mt_iommu_domain_alloc(&bus));
 devices[1].domain=NULL; fail_alloc=true; assert(!mt_iommu_domain_alloc(&bus));
 assert(devices[0].refs==0 && devices[1].refs==0);
 return 0;
}
'''
        compile_run(code)

if __name__ == '__main__': unittest.main()
