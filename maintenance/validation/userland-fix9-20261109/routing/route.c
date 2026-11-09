#define _GNU_SOURCE
#include <assert.h>
#include <dlfcn.h>
#include <link.h>
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

static void block_graphics_io(void)
{
    struct sock_filter filter[] = {
        BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, nr)),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_ioctl, 2, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_connect, 1, 0),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),
    };
    struct sock_fprog program = {.len = sizeof filter / sizeof *filter, .filter = filter};
    assert(prctl(PR_SET_NO_NEW_PRIVS, 1L, 0L, 0L, 0L) == 0);
    assert(prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &program) == 0);
}

static int mapped(struct dl_phdr_info *i, size_t n, void *arg)
{
    (void)n;
    (void)arg;
    const char *slash = strrchr(i->dlpi_name, '/');
    const char *name = slash ? slash + 1 : i->dlpi_name;
    if (strcmp(name, "mtgpu_dri.so") && strcmp(name, "musa_dri.so"))
        return 0;
    char *absolute = realpath(i->dlpi_name, NULL);
    assert(absolute);
    printf("mapped=%s\n", absolute);
    free(absolute);
    return 0;
}

int main(int argc, char **argv)
{
    assert(argc == 3 && getuid() != 0 && getuid() == geteuid());
    block_graphics_io();
    void *egl = dlopen(argv[1], RTLD_LOCAL | RTLD_NOW);
    assert(egl);
    struct link_map *map;
    assert(!dlinfo(egl, RTLD_DI_LINKMAP, &map));
    typedef const void **(*loader_fn)(const char *, void **, const char **);
    loader_fn open_driver = (loader_fn)(map->l_addr + strtoul(argv[2], NULL, 16));
    void *primary = NULL;
    const char *path_vars[] = {"LIBGL_DRIVERS_PATH", NULL};
    const void **extensions = open_driver("mtgpu", &primary, path_vars);
    printf("extensions=%d\n", extensions != NULL && primary != NULL);
    dl_iterate_phdr(mapped, NULL);
    return 0;
}
