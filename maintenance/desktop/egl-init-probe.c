/* SPDX-License-Identifier: MIT
 * Initialization-only protocol control; no context, surface or draw call.
 */
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <wayland-client.h>
#include <stdio.h>
int main(void)
{
    struct wl_display *wl = wl_display_connect(NULL);
    if (!wl) return 3;
    PFNEGLGETPLATFORMDISPLAYEXTPROC get = (void *)eglGetProcAddress("eglGetPlatformDisplayEXT");
    if (!get) return 3;
    EGLDisplay d = get(EGL_PLATFORM_WAYLAND_EXT, wl, NULL);
    EGLint error = eglGetError();
    printf("display=%p error=0x%x\n", (void *)d, error); fflush(stdout);
    if (d == EGL_NO_DISPLAY) return 2;
    EGLBoolean ok = eglInitialize(d, NULL, NULL);
    error = eglGetError();
    printf("initialize=%u error=0x%x\n", ok, error);
    if (ok) eglTerminate(d);
    wl_display_disconnect(wl);
    return ok ? 0 : 2;
}
