#!/usr/bin/env python3
"""Execute maintained C against fault-injecting MMIO/IRQ/resource models.

These tests validate software ordering and bounds, not real GPU completion.
"""
import pathlib
import unittest
from test_wrappers import SOURCE, compile_run, function

TREE = SOURCE.parents[2]


def header(name):
    return '\n'.join(line for line in (TREE / 'inc' / name).read_text().splitlines()
                     if not line.startswith('#include '))


class RuntimeInit(unittest.TestCase):
    def test_display_stop_requires_fresh_hardware_completion(self):
        code = r'''
#include <assert.h>
#include <stdint.h>
#include <stddef.h>
#include <errno.h>
#include <string.h>
typedef uint32_t u32;
#define __iomem
#define BIT(n) (1U << (n))
static u32 regs[16];
static unsigned writes, polls, pending, completion_delay;
static int allow_completion;
static u32 readl(void *addr) {
 size_t off = (u32 *)addr - regs;
 assert(off < 16);
 if (off == 6 && pending && allow_completion && ++polls >= completion_delay) {
  regs[6] |= 0x100; pending = 0;
 }
 return regs[off];
}
static void writel(u32 value, void *addr) {
 size_t off = (u32 *)addr - regs;
 assert(off < 16); writes++;
 if (off == 6) { assert(value == 0x100); regs[6] &= ~value; }
 else {
  if (off == 0) {
   assert(!(regs[6] & 0x100)); /* stale completion cleared first */
   assert(regs[7] == 0); /* interrupt mask stays off */
   assert((value ^ regs[0]) == 1); /* preserve all other control bits */
   pending = 1;
  }
  regs[off] = value;
 }
}
/* Deterministic time model: one iteration per polling interval. */
#define readl_poll_timeout(addr,val,cond,delay,timeout) ({ \
 int result=-ETIMEDOUT; \
 assert((delay)==1000 && (timeout)==500000); \
 for (unsigned n=0; n<=(timeout)/(delay);n++) { \
  (val)=readl(addr); if(cond) {result=0;break;} \
 } result; })
static void reset(int enabled, int completes) {
 memset(regs,0,sizeof regs); writes=polls=pending=0;
 regs[0]=0xa50 | enabled; regs[6]=0x124; regs[7]=0xffff;
 allow_completion=completes; completion_delay=4;
}
'''
        code += header('s30_runtime_compat.h')
        code += r'''
int main(void) {
 reset(1,1); assert(mtgpu_s30_stop_firmware(regs)==0);
 assert(regs[0]==0xa50 && regs[6]==0x24 && regs[7]==0);
 assert(polls>=4 && writes==4);
 reset(1,0); assert(mtgpu_s30_stop_firmware(regs)==-ETIMEDOUT);
 assert(regs[6]==0x24 && regs[7]==0 && writes==3);
 /* The stale bit alone must never count as a new completion. */
 assert(pending && polls==0);
 reset(0,0); assert(mtgpu_s30_stop_firmware(regs)==0);
 assert(writes==1 && pending==0 && regs[6]==0x124);
 writes=0; assert(mtgpu_s30_stop_firmware(NULL)==-EINVAL && writes==0);
 reset(0,0);regs[0]=UINT32_MAX;writes=0;
 assert(mtgpu_s30_stop_firmware(regs)==-ENODEV && writes==0);
 return 0;
}
'''
        compile_run(code)

    def test_vpu_profile_and_bar_boundary_fail_closed(self):
        code = r'''
#include <assert.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
typedef uint32_t u32;
typedef uint64_t u64;
#define TYPE_SUDI 0
#define CODA980_CODE 0x9800
#define WAVE517_CODE 0x5170
#define WAVE627_CODE 0x6270
struct mt_conf {u32 type,regs_base,regs_chip_size,regs_core_size[24];
 u32 regs_top_offset,regs_ata_offset,core_base,core_size,product[24];};
'''
        code += header('s30_vpu_compat.h')
        code += r'''
int main(void) {
 struct mt_conf original = {.regs_base=0x108000,.regs_chip_size=0xf000,
  .regs_core_size={0x4000,0x4000,0x4000},.regs_top_offset=0xd000,
  .core_size=3,.product={CODA980_CODE,WAVE517_CODE,WAVE627_CODE}};
 struct mt_conf c=original;
 u32 size=0xdead;
 assert(mtgpu_s30_vpu_map_size(&c,0x2000000,0x116000,&size)==0);
 assert(size==0xe000 && c.regs_base+size==0x116000);
 assert(!memcmp(&c,&original,sizeof c)); /* vendor ABI/config unchanged */
 assert(c.regs_top_offset+0x1000<=size);
 assert(c.regs_core_size[0]+c.regs_core_size[1]+c.regs_core_size[2]<=size);
 /* Every profile field used to justify the reduced mapping is checked. */
 u32 *fields[]={&c.type,&c.regs_base,&c.regs_chip_size,&c.core_size,
  &c.regs_top_offset,&c.regs_ata_offset,&c.regs_core_size[0],
  &c.regs_core_size[1],&c.regs_core_size[2],&c.product[0],
  &c.product[1],&c.product[2]};
 for (unsigned i=0;i<sizeof fields/sizeof fields[0];i++) {
  *fields[i]^=1;size=0xdead;
  assert(mtgpu_s30_vpu_map_size(&c,0x2000000,0x116000,&size)==-EINVAL);
  assert(size==0xdead); *fields[i]^=1;
 }
 u64 bad_bars[]={0,0x107fff,0x108000,0x115fff};
 for(unsigned i=0;i<sizeof bad_bars/sizeof bad_bars[0];i++)
  assert(mtgpu_s30_vpu_map_size(&c,bad_bars[i],0x116000,&size)==-ERANGE);
 assert(mtgpu_s30_vpu_map_size(&c,0x116000,0x116000,&size)==0);
 u64 bad_display[]={0,0x115fff,0x117000,UINT64_MAX};
 for(unsigned i=0;i<sizeof bad_display/sizeof bad_display[0];i++)
  assert(mtgpu_s30_vpu_map_size(&c,0x2000000,bad_display[i],&size)==-ERANGE);
 return 0;
}
'''
        compile_run(code)

    def test_early_and_teardown_irq_ack_without_crtc_access(self):
        code = r'''
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
typedef uint32_t u32;
#define DISPC_INT_BIT_VSYNC 2
#define DISPC_INT_BIT_UNDERRUN 4
#define smp_load_acquire(p) (*(p))
struct mtgpu_drm_private {bool display_irqs_ready;};
struct drm_device {struct mtgpu_drm_private *dev_private;};
struct mtgpu_dispc_ctx {bool dsc_en;};
struct core_ops {u32 (*isr)(struct mtgpu_dispc_ctx *);};
struct mtgpu_dispc {void *crtc;struct mtgpu_dispc_ctx ctx;
 struct core_ops *core;struct drm_device *drm;
 struct {unsigned underrun_cnt;} debugfs;};
static unsigned acks,vblanks,dscs;
static u32 hw_isr(struct mtgpu_dispc_ctx *ctx) {acks++;return 6;}
static void drm_crtc_handle_vblank(void *crtc) {assert(crtc);vblanks++;}
static void mtgpu_dispc_dsc_status(struct mtgpu_dispc *dispc) {dscs++;}
'''
        code += function((TREE / 'src/mtgpu/mtgpu_drm_dispc.c').read_text(),
                         'mtgpu_dispc_isr')
        code += r'''
int main(void) {
 struct mtgpu_drm_private p={0};struct drm_device drm={&p};
 struct core_ops ops={hw_isr};
 struct mtgpu_dispc d={.ctx={true},.core=&ops,.drm=&drm};
 mtgpu_dispc_isr(&d);assert(acks==1 && !vblanks && !dscs);
 d.crtc=&d;p.display_irqs_ready=true;
 mtgpu_dispc_isr(&d);assert(acks==2 && vblanks==1 && dscs==1);
 assert(d.debugfs.underrun_cnt==1);
 p.display_irqs_ready=false;d.crtc=(void *)1; /* already invalidated */
 mtgpu_dispc_isr(&d);assert(acks==3 && vblanks==1 && dscs==1);
 return 0;
}
'''
        compile_run(code)

    def test_irq_sync_uses_allocated_host_irqs(self):
        code = r'''
#include <assert.h>
#include <stdint.h>
#include <stddef.h>
typedef uint32_t u32;
struct mtgpu_irq_data {int target,host_irq;};
struct mtgpu_irq_info {u32 irq_cnt;struct mtgpu_irq_data *irq_data;};
struct mtgpu_device {struct mtgpu_irq_info *irq_info;};
struct device {struct mtgpu_device *data;};
static struct mtgpu_device *dev_get_drvdata(struct device *d) {return d->data;}
static int seen[8],count;
static void synchronize_irq(int irq) {assert(count<8);seen[count++]=irq;}
'''
        code += function((TREE / 'src/mtgpu/mtgpu_drm_drv.c').read_text(),
                         'mtgpu_drm_sync_irqs')
        code += r'''
int main(void) {
 struct mtgpu_irq_data vectors[]={{0,82},{1,87},{2,90}};
 struct mtgpu_irq_info i={3,vectors};struct mtgpu_device mt={&i};
 struct device dev={&mt};mtgpu_drm_sync_irqs(&dev);
 assert(count==3 && seen[0]==82 && seen[1]==87 && seen[2]==90);
 i.irq_data=NULL;mtgpu_drm_sync_irqs(&dev);assert(count==3);
 mt.irq_info=NULL;mtgpu_drm_sync_irqs(&dev);assert(count==3);
 dev.data=NULL;mtgpu_drm_sync_irqs(&dev);assert(count==3);
 return 0;
}
'''
        compile_run(code)


if __name__ == '__main__':
    unittest.main(verbosity=2)
