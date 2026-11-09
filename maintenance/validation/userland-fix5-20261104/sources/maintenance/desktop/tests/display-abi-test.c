/* CPU-only probes of the exact vendor screen/drawable dispatch. GDB must stop
 * and kill before any device helper or buffer operation. A syscall filter is
 * installed before the probe marker as an independent fail-closed guard. */
#include "egl_dri2.h"
#include <assert.h>
#include <dirent.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <link.h>
#include <linux/audit.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <unistd.h>

uintptr_t vendor_base;
void *probe_loader_private;
int probe_guard_enabled;
int probe_delegate_calls;

static __DRIdrawable *stub_delegate_drawable(__DRIscreen *screen,
   const __DRIconfig *config, void *data)
{
   /* The minimal branch-test screen has no initialized nested musa screen.
    * Record this optional constructor call; do not run an unbounded lower
    * driver constructor merely to test mtgpu's subsequent platform branch. */
   ++probe_delegate_calls;
   return NULL;
}

static __DRIscreen *capture_screen_private(int screen, int fd,
   const __DRIextension **loaders, const __DRIextension **drivers,
   const __DRIconfig ***configs, void *data)
{
   assert(screen == 0 && fd == -1);
   probe_loader_private = data;
   return NULL; /* Let real EGL return normally without any real constructor. */
}

__attribute__((noinline)) static void probe_ready(void)
{
   __asm__ volatile("" ::: "memory");
}

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

static void *open_library(const char *path, uintptr_t *base)
{
   void *library = dlopen(path, RTLD_NOW | RTLD_LOCAL);
   if (!library) {
      fprintf(stderr, "%s\n", dlerror());
      exit(3);
   }
   struct link_map *map = NULL;
   assert(!dlinfo(library, RTLD_DI_LINKMAP, &map) && map);
   *base = map->l_addr;
   return library;
}

int main(int argc, char **argv)
{
   assert(argc == 7);
   const char *phase = argv[1], *mode = argv[2];
   uintptr_t egl_base;
   open_library(argv[3], &egl_base);
   void *library = open_library(argv[5], &vendor_base);
   const __DRIextension **(*get_extensions)(void) =
      dlsym(library, "__driDriverGetExtensions_mtgpu");
   assert(get_extensions);
   const __DRIextension **extensions = get_extensions();
   const __DRIimageDriverExtension *image_driver = NULL;
   for (unsigned i = 0; extensions[i]; ++i)
      if (!strcmp(extensions[i]->name, __DRI_IMAGE_DRIVER))
         image_driver = (const void *)extensions[i];
   assert(image_driver && image_driver->base.version == 1);

   __DRImesaCoreExtension mesa = { .createNewScreen = capture_screen_private };
   struct dri2_egl_display driver = {
      .driver_name = "mtgpu", .fd_render_gpu = -1, .fd_display_gpu = -1, .mesa = &mesa,
   };
   _EGLDisplay display = {
      .DriverData = &driver, .Platform = _EGL_PLATFORM_WAYLAND,
      .PlatformDisplay = (void *)(uintptr_t)0x12345678,
   };
   __DRIimageLoaderExtension image_loader = { .base = {__DRI_IMAGE_LOADER, 2} };
   __DRIimageLookupExtension lookup = { .base = {__DRI_IMAGE_LOOKUP, 1} };
   const __DRIextension *loaders[] = { &image_loader.base, &lookup.base, NULL };
   const __DRIconfig **configs = NULL;
   const __DRIextension *empty_driver_extensions[] = { NULL };
   unsigned char screen[0xb8] = {0}, native[0x40] = {0};
   unsigned char config[212] = {0}, surface[2048] = {0};
   int native_type = atoi(argv[6]);
   memcpy(native, &native_type, sizeof(native_type));
   void *native_pointer = native, *image_pointer = &image_loader;
   memcpy(screen + 0x10, &native_pointer, sizeof(native_pointer));
   memcpy(screen + 0x60, &image_pointer, sizeof(image_pointer));
   guard_no_device_access();
   EGLBoolean (*create_screen)(_EGLDisplay *) =
      (void *)(egl_base + strtoull(argv[4], NULL, 16));
   assert(!create_screen(&display) && probe_loader_private);
   if (!strcmp(mode, "candidate"))
      assert(probe_loader_private != &display);
   else
      assert(!strcmp(mode, "baseline") && probe_loader_private == &display);
   __DRIimageDriverExtension delegate_stub = {
      .base = { __DRI_IMAGE_DRIVER, 1 }, .createNewDrawable = stub_delegate_drawable,
   };
   if (!strcmp(phase, "drawable")) {
      /* Pinned vendor mutable delegate table, in this throwaway process only.
       * The disk binary and mtgpu createNewDrawable instructions are intact. */
      const __DRIimageDriverExtension **slot = (void *)(vendor_base + 0x1102c48);
      assert(*slot);
      *slot = &delegate_stub;
   }
   probe_ready();
   if (!strcmp(phase, "screen")) {
      /* The public callback maps to the pinned vendor screen constructor.
       * -1 skips the ioctl path; GDB kills before its first device helper. */
      image_driver->createNewScreen2(0, -1, loaders, empty_driver_extensions,
                                    &configs, probe_loader_private);
   } else if (!strcmp(phase, "drawable")) {
      /* native_type is the output of the preceding real screen-dispatch
       * probe, not a hand-written prediction of that code. No valid screen
       * is constructed: stop before either selected drawable branch runs. */
      image_driver->createNewDrawable((void *)screen, (const void *)config, surface);
   } else if (!strcmp(phase, "guard-ioctl")) {
      syscall(SYS_ioctl, -1, 0, 0); /* Invalid fd even if the guard is broken. */
   } else {
      assert(!strcmp(phase, "guard-open"));
      syscall(SYS_openat, AT_FDCWD, "/dev/null", O_RDONLY, 0);
   }
   /* A constructor returning means the debugger failed to stop as required. */
   abort();
}
