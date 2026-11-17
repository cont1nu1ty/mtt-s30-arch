/* SPDX-License-Identifier: MIT */
#include <glvnd/libeglabi.h>
#include "mtgpu_guard_common.h"

#ifndef GUARD_TARGET_PATH
#define GUARD_TARGET_PATH "/usr/lib/libEGL_mtgpu.so.0"
#endif

static pthread_mutex_t g_egl_lock = PTHREAD_MUTEX_INITIALIZER;
static void *g_target_handle = NULL;
static __PFNEGLMAINPROC g_real_egl_main = NULL;

/**
 * GLVND vendor entrypoint guard: silently decline registration when mtgpu
 * is unavailable or fallback mode is active so libEGL falls back to Mesa.
 */
__attribute__((visibility("default")))
EGLBoolean __egl_Main(uint32_t version, const __EGLapiExports *exports,
                      __EGLvendorInfo *vendor, __EGLapiImports *imports)
{
    __PFNEGLMAINPROC real_main = NULL;
    EGLBoolean ok;

    if (!mtgpu_guard_is_active())
        return EGL_FALSE;

    pthread_mutex_lock(&g_egl_lock);
    if (!g_real_egl_main) {
        g_target_handle = dlopen(GUARD_TARGET_PATH, RTLD_LAZY | RTLD_LOCAL);
        if (g_target_handle) {
            g_real_egl_main = (__PFNEGLMAINPROC)dlsym(g_target_handle, __EGL_MAIN_PROTO_NAME);
            if (!g_real_egl_main) {
                dlclose(g_target_handle);
                g_target_handle = NULL;
            }
        }
    }
    real_main = g_real_egl_main;
    pthread_mutex_unlock(&g_egl_lock);

    if (!real_main)
        return EGL_FALSE;

    ok = real_main(version, exports, vendor, imports);
    return ok;
}
