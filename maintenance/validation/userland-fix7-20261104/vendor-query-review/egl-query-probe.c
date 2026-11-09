/* CPU-only execution of unmodified vendor leaf/table-query instruction bytes.
 * mmap does not run any ELF initialization or construct any driver/screen.
 * All device/open/socket syscalls are killed before executing mapped code.
 * EGL driver query, full DRI format query, and secondary bind branches run
 * unmodified. Only bounded TLS storage and downstream bind callbacks are fixtures.
 */
#define _GNU_SOURCE
#include <assert.h>
#include <elf.h>
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



static uint8_t *map_image(const char *path) {
 int fd=open(path,O_RDONLY); assert(fd>=0);
 struct stat st; assert(!fstat(fd,&st));
 uint8_t *file=mmap(NULL,st.st_size,PROT_READ,MAP_PRIVATE,fd,0); close(fd);
 assert(file!=MAP_FAILED);
 Elf64_Ehdr *eh=(void*)file; assert(!memcmp(eh->e_ident,ELFMAG,SELFMAG));
 Elf64_Phdr *ph=(void*)(file+eh->e_phoff); size_t size=0;
 for(unsigned i=0;i<eh->e_phnum;i++) if(ph[i].p_type==PT_LOAD && size<ph[i].p_vaddr+ph[i].p_memsz)size=ph[i].p_vaddr+ph[i].p_memsz;
 size=(size+4095)&~(size_t)4095;
 uint8_t *image=mmap(NULL,size,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(image!=MAP_FAILED);
 for(unsigned i=0;i<eh->e_phnum;i++) if(ph[i].p_type==PT_LOAD) {
   assert(ph[i].p_offset+ph[i].p_filesz<=(size_t)st.st_size);
   memcpy(image+ph[i].p_vaddr,file+ph[i].p_offset,ph[i].p_filesz);
   size_t start=ph[i].p_vaddr&~(size_t)4095,end=(ph[i].p_vaddr+ph[i].p_memsz+4095)&~(size_t)4095;
   int prot=((ph[i].p_flags&PF_R)?PROT_READ:0)|((ph[i].p_flags&PF_W)?PROT_WRITE:0)|((ph[i].p_flags&PF_X)?PROT_EXEC:0);
   assert(!mprotect(image+start,end-start,prot));
 }
 assert(!munmap(file,st.st_size)); return image;
}
static uintptr_t fixture_tls[9];
static int tls_calls, secondary_bind_calls, secondary_unbind_calls;
static void *secondary_context;
static void *tls_fixture(void *descriptor) { assert(descriptor); ++tls_calls; return fixture_tls; }
static int secondary_bind_fixture(void *context,void *draw,void *read) {
 assert(context==secondary_context && !draw && !read); ++secondary_bind_calls;return 1;
}
static int secondary_unbind_fixture(void *context) { assert(context==secondary_context);++secondary_unbind_calls;return 1; }
static void array(const char *name,int *values,int count) {
 printf("\"%s\":[",name);for(int i=0;i<count;i++)printf("%s%u",i?",":"",(unsigned)values[i]);printf("]");
}
int main(int argc,char **argv) {
 assert(argc==4);setvbuf(stdout,NULL,_IONBF,0);
 uint8_t *egl=map_image(argv[1]),*mtgpu=map_image(argv[2]),*musa=map_image(argv[3]);
 typedef int(*fmtfn)(void*,int,int*,int*);
 typedef int(*modfn)(void*,int,int,uint64_t*,unsigned*,int*);
 fmtfn query=(void*)(egl+0x31010),primary_query=(void*)(mtgpu+0x6e2450),secondary_query=(void*)(musa+0x15740);
 modfn modifiers=(void*)(mtgpu+0x6e2520);
 int(*bind)(void*,void*,void*)=(void*)(mtgpu+0x6e3970);
 int(*unbind)(void*)=(void*)(mtgpu+0x6e38e0);
 _Alignas(16) uint8_t display[0x78]={0},dri_display[0x70]={0},screen[0xb8]={0},native[0x20]={0};
 _Alignas(16) uint8_t primary_image[0xb0]={0},secondary_image[0xb0]={0},secondary_core[0x78]={0},context[0x38]={0};
 _Alignas(16) uint8_t support[0x30]={0};uint8_t mask[31];memset(mask,1,sizeof(mask));
 *(void**)(display+0x70)=dri_display;*(void**)(dri_display+0x10)=screen;*(void**)(dri_display+0x68)=primary_image;
 *(int*)(primary_image+8)=20;*(void**)(primary_image+0xa0)=(void*)primary_query;
 *(void**)(secondary_image+0xa0)=(void*)secondary_query;
 *(void**)(secondary_core+0x68)=(void*)secondary_bind_fixture;*(void**)(secondary_core+0x70)=(void*)secondary_unbind_fixture;
 *(void**)(screen+0x10)=native;*(int*)native=4;*(void**)(screen+0xb0)=support;
 *(int*)(support+0x20)=31;*(void**)(support+0x28)=mask;
 secondary_context=(void*)0x1234;*(void**)(context+0x30)=secondary_context;
 /* Fake dynamic data only: original instructions are unchanged. TLS resolver
  * and secondary core bind callbacks are stubs, never real driver context work. */
 *(void**)(mtgpu+0x10b58c8)=(void*)tls_fixture;
 *(void**)(mtgpu+0x1102c40)=secondary_core;*(void**)(mtgpu+0x1102c70)=secondary_image;
 guard_no_device_access();
 int before[64],after[64],primary[64],again[64],survivors[64],nb=0,na=0,np=0,nr=0,ns=0;
 assert(query(display,64,before,&nb)==1 && nb==22);
 int saved_tls_calls=tls_calls;assert(fixture_tls[1]==0);
 assert(bind(context,NULL,NULL)==1 && secondary_bind_calls==1 && tls_calls==saved_tls_calls && fixture_tls[1]==0);
 assert(query(display,64,after,&na)==1 && na==22 && !memcmp(before,after,na*sizeof(int)));
 for(int i=0;i<na;i++) {
  int count=-1;uint64_t mods[4]={0};unsigned external[4]={0};
  if(modifiers(screen,after[i],0,NULL,NULL,&count)) {
   int actual=-1;assert(count>0 && count<=4 && modifiers(screen,after[i],4,mods,external,&actual));
   assert(actual==count && mods[0]==0 && external[0]==0);survivors[ns++]=after[i];
  }
 }
 assert(ns==8);
 /* Explicit synthetic primary TLS state; this does NOT create/bind a context. */
 fixture_tls[1]=0x5678;assert(query(display,64,primary,&np)==1 && np==18);
 fixture_tls[1]=0;assert(query(display,64,again,&nr)==1 && nr==22 && !memcmp(before,again,nr*sizeof(int)));
 saved_tls_calls=tls_calls;assert(unbind(context)==1 && secondary_unbind_calls==1 && tls_calls==saved_tls_calls && fixture_tls[1]==0);
 printf("{\"guard_enabled\":true,\"original_instruction_bytes_unchanged\":true,\"egl_wrapper_no_cache_22_18_22\":true,\"secondary_bind_tls_calls\":0,\"secondary_unbind_tls_calls\":0,\"secondary_bind_calls\":%d,",secondary_bind_calls);
 array("before_secondary_bind",before,nb);printf(",");array("after_secondary_bind",after,na);printf(",");array("after_primary_modifiers",survivors,ns);printf(",");array("synthetic_primary_tls_formats",primary,np);printf("}\n");
 _exit(0);
}
