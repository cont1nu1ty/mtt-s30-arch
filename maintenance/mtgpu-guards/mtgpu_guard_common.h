/* SPDX-License-Identifier: MIT */
#ifndef MTGPU_GUARD_COMMON_H
#define MTGPU_GUARD_COMMON_H

#include <ctype.h>
#include <dirent.h>
#include <dlfcn.h>
#include <limits.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int mtgpu_cmdline_requests_fallback(void)
{
    FILE *fp = fopen("/proc/cmdline", "r");
    char buf[4096];
    char *tok;
    char *saveptr = NULL;

    if (!fp)
        return 0;

    if (!fgets(buf, sizeof(buf), fp)) {
        fclose(fp);
        return 0;
    }
    fclose(fp);

    for (tok = strtok_r(buf, " \t\r\n", &saveptr); tok; tok = strtok_r(NULL, " \t\r\n", &saveptr)) {
        if (strcmp(tok, "nomtgpu") == 0 ||
            strcmp(tok, "mtgpu.fallback=1") == 0 ||
            strcmp(tok, "modprobe.blacklist=mtgpu") == 0) {
            return 1;
        }
        /* Handle comma-separated module blacklist lists: modprobe.blacklist=foo,mtgpu */
        if (strncmp(tok, "modprobe.blacklist=", 19) == 0) {
            char *list = tok + 19;
            char *item;
            char *subsave = NULL;
            for (item = strtok_r(list, ",", &subsave); item; item = strtok_r(NULL, ",", &subsave)) {
                if (strcmp(item, "mtgpu") == 0)
                    return 1;
            }
        }
    }
    return 0;
}

static int mtgpu_drm_entry_is_mtgpu(const char *entry)
{
    char link_path[PATH_MAX];
    char resolved[PATH_MAX];
    ssize_t len;
    const char *base;

    snprintf(link_path, sizeof(link_path), "/sys/class/drm/%s/device/driver", entry);
    len = readlink(link_path, resolved, sizeof(resolved) - 1);
    if (len <= 0)
        return 0;
    resolved[len] = '\0';

    base = strrchr(resolved, '/');
    base = base ? base + 1 : resolved;
    return strcmp(base, "mtgpu") == 0;
}

static int mtgpu_name_has_digits_only(const char *s)
{
    if (!s || !*s)
        return 0;
    for (; *s; s++) {
        if (!isdigit((unsigned char)*s))
            return 0;
    }
    return 1;
}

/**
 * Check whether the mtgpu kernel module is active, a DRM primary card and
 * render node are bound to mtgpu, and fallback mode has not been requested.
 */
static int mtgpu_guard_is_active(void)
{
    const char *force = getenv("MTGPU_FORCE_FALLBACK");
    DIR *dir;
    struct dirent *de;
    int has_card = 0;
    int has_render = 0;

    if (force && strcmp(force, "1") == 0)
        return 0;

    if (access("/run/mtgpu-fallback", F_OK) == 0 ||
        access("/etc/mtgpu-fallback", F_OK) == 0 ||
        access("/sys/module/mtgpu", F_OK) != 0)
        return 0;

    if (mtgpu_cmdline_requests_fallback())
        return 0;

    dir = opendir("/sys/class/drm");
    if (!dir)
        return 0;

    while ((de = readdir(dir)) != NULL) {
        char dev_path[PATH_MAX];
        struct stat st;

        if (strncmp(de->d_name, "card", 4) == 0 && mtgpu_name_has_digits_only(de->d_name + 4)) {
            if (!mtgpu_drm_entry_is_mtgpu(de->d_name))
                continue;
            snprintf(dev_path, sizeof(dev_path), "/dev/dri/%s", de->d_name);
            if (stat(dev_path, &st) == 0 && S_ISCHR(st.st_mode))
                has_card = 1;
        } else if (strncmp(de->d_name, "renderD", 7) == 0 && mtgpu_name_has_digits_only(de->d_name + 7)) {
            if (!mtgpu_drm_entry_is_mtgpu(de->d_name))
                continue;
            snprintf(dev_path, sizeof(dev_path), "/dev/dri/%s", de->d_name);
            if (access(dev_path, R_OK | W_OK) == 0)
                has_render = 1;
        }
    }

    closedir(dir);
    return has_card && has_render;
}

#endif /* MTGPU_GUARD_COMMON_H */
