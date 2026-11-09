/* CPU-only execution of unmodified vendor leaf/table-query instruction bytes.
 * mmap does not run any ELF initialization or construct any driver/screen.
 * All device/open/socket syscalls are killed before executing mapped code.
 * Primary format wrapper starts AFTER TLS routing, with its prologue recreated.
 */
#define _GNU_SOURCE
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <linux/audit.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <unistd.h>
int probe_guard_enabled;
static void guard_no_device_access(void)
{
   DIR *fds = opendir("/proc/self/fd");
   assert(fds);
   struct dirent *entry;
   while ((entry = readdir(fds))) {
      if (entry->d_name[0] == '.')
         continue;
      char name[300], target[1024];
      assert(snprintf(name, sizeof(name), "/proc/self/fd/%s", entry->d_name) > 0);
      ssize_t length = readlink(name, target, sizeof(target) - 1);
      assert(length > 0);
      target[length] = 0;
      assert(strncmp(target, "/dev/dri/", 9) && strncmp(target, "/dev/musa", 9));
   }
   closedir(fds);
#define DENY_SYSCALL(n) \
   BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, (n), 0, 1), \
   BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS)
   struct sock_filter filter[] = {
      BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, arch)),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, AUDIT_ARCH_X86_64, 1, 0),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),
      BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, nr)),
      DENY_SYSCALL(SYS_ioctl),
      DENY_SYSCALL(SYS_open),
      DENY_SYSCALL(SYS_openat),
      DENY_SYSCALL(SYS_openat2),
      DENY_SYSCALL(SYS_socket),
      DENY_SYSCALL(SYS_socketpair),
      DENY_SYSCALL(SYS_connect),
      DENY_SYSCALL(SYS_io_uring_setup),
      DENY_SYSCALL(SYS_io_uring_enter),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
   };
#undef DENY_SYSCALL
   struct sock_fprog program = { .len = sizeof(filter) / sizeof(filter[0]), .filter = filter };
   assert(!prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0));
   assert(!prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &program));
   probe_guard_enabled = 1;
}


static uint8_t *map_code(const char *path) {
 int fd=open(path,O_RDONLY); assert(fd>=0);
 struct stat st; assert(fstat(fd,&st)==0);
 void *p=mmap(NULL,st.st_size,PROT_READ|PROT_EXEC,MAP_PRIVATE,fd,0);
 assert(p!=MAP_FAILED); close(fd); return p;
}
extern int query_primary(void*, int, int*, int*);
__asm__(
".text\n.globl query_primary\n.type query_primary,@function\n"
"query_primary:\npush %r13\npush %r12\npush %rbp\npush %rbx\nsub $8,%rsp\n"
"mov %esi,%ebx\nmov %rdx,%rbp\nmov %rcx,%r12\njmp *%rdi\n"
".size query_primary,.-query_primary\n");
int main(int argc,char **argv) {
 assert(argc==4); setvbuf(stdout,NULL,_IONBF,0);
 uint8_t *mtgpu=map_code(argv[1]),*musa=map_code(argv[2]),*gbm=map_code(argv[3]);
 typedef int(*modfn)(void*,int,int,uint64_t*,unsigned*,int*);
 typedef int(*fmtfn)(void*,int,int*,int*);
 modfn mod=(modfn)(mtgpu+0x6e2520);
 fmtfn mf=(fmtfn)(musa+0x15740);
 _Alignas(16) unsigned char screen[0xb8]={0},native[0x20]={0},support[0x30]={0};
 _Alignas(16) unsigned char dev[0x140]={0},image[0xb0]={0};
 *(void**)(dev+0xe0)=screen; *(void**)(dev+0x130)=image;
 *(int*)(image+8)=20; *(void**)(image+0xa8)=(void*)mod;
 unsigned char mask[31]; memset(mask,1,sizeof(mask));
 *(void**)(screen+0x10)=native;
 *(int*)(support+0x20)=31; *(void**)(support+0x28)=mask;
 guard_no_device_access();
 int primary[64],np=0; assert(query_primary(mtgpu+0x6e247b,64,primary,&np)==1 && np==18);
 printf("{\"guard_enabled\":true,\"primary_formats\":[");
 for(int i=0;i<np;i++)printf("%s%u",i?",":"",(unsigned)primary[i]);
 puts("],\"modifier_queries\":[");
 for(int kind=0;kind<=4;kind+=4) {
  *(int*)native=kind;
  for(int i=0;i<np+1;i++) {
   int f=i<np?primary[i]:0x34324258;
   int nc=-1,n=-1; uint64_t mods[4]={0}; unsigned ext[4]={0};
   int rc=mod(screen,f,0,NULL,NULL,&nc),ret=mod(screen,f,4,mods,ext,&n);
   printf("%s{\"kind\":%d,\"fourcc\":%u,\"count_ok\":%d,\"count\":%d,\"list_ok\":%d,\"list_count\":%d,\"modifiers\":[",kind||i?",":"",kind,(unsigned)f,rc,nc,ret,n);
   for(int j=0;j<n;j++)printf("%s\"0x%016lx\"",j?",":"",mods[j]);
   printf("],\"external_only\":[");for(int j=0;j<n;j++)printf("%s%u",j?",":"",ext[j]);printf("]}\n");
  }
 }
 int fmts[64],n=0; assert(mf(support,64,fmts,&n)==1);
 printf("],\"musa_historical_mask_all_31_enabled_formats\":[");
 for(int i=0;i<n;i++) { printf("%s%u",i?",":"",(unsigned)fmts[i]); }
 puts("],\"gbm_format_support_query\":[");
 int (*gbm_supported)(void*,uint32_t,uint32_t)=(void*)(gbm+0x1680);
 *(int*)native=4;
 for(int i=0;i<np+1;i++) {
  unsigned f=i<np?(unsigned)primary[i]:0x34324258;
  int ret=gbm_supported(dev,f,4);
  printf("%s{\"fourcc\":%u,\"supported\":%d}",i?",":"",f,ret);
 }
 puts("]}");
 _exit(0);
}
