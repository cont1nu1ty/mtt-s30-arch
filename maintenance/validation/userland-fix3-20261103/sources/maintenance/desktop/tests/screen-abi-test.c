#include "egl_dri2.h"
#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

/* No driver, DRM fd, or actual screen is created by this regression test.
 * The screen page is deliberately unreadable. Only the public test callback
 * may receive its address, and that callback does not dereference it. */
static __DRIscreen *opaque;
static unsigned calls;
static unsigned mask;
static unsigned int api_mask(__DRIscreen *screen)
{
   assert(screen == opaque);
   ++calls;
   return mask;
}

static int global_names(__DRIscreen *screen)
{
   assert(screen == opaque);
   return __DRI_IMAGE_CAP_GLOBAL_NAMES;
}

static __DRIimage *from_name(__DRIscreen *screen, int width, int height,
                            int format, int name, int pitch, void *data)
{
   (void)screen; (void)width; (void)height; (void)format;
   (void)name; (void)pitch; (void)data;
   assert(!"setup must not actually import an image");
   return NULL;
}

static __DRIimage *from_names(__DRIscreen *screen, int width, int height,
                             int format, int *names, int count, int *strides,
                             int *offsets, void *data)
{
   (void)screen; (void)width; (void)height; (void)format; (void)names;
   (void)count; (void)strides; (void)offsets; (void)data;
   assert(!"extension setup must not import an image");
   return NULL;
}

void _eglLog(EGLint level, const char *fmt, ...)
{
   (void)level;
   (void)fmt;
}

int main(int argc, char **argv)
{
   assert(argc == 2);
   int mode = atoi(argv[1]);
   opaque = mmap(NULL, 4096, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   assert(opaque != MAP_FAILED);
   __DRIimageDriverExtension image_driver = {
      .base = {__DRI_IMAGE_DRIVER, 1}, .getAPIMask = api_mask,
   };
   __DRIdri2Extension dri2 = {
      .base = {__DRI_DRI2, 4}, .getAPIMask = api_mask,
   };
   __DRIimageExtension image = {.base = {__DRI_IMAGE, 6}};
   __DRI2fenceExtension fence = {.base = {__DRI2_FENCE, 1}};
   struct dri2_egl_display driver = {
      .driver_name = "mtgpu", .dri_screen_render_gpu = opaque,
      .image_driver = &image_driver, .image = &image, .device_name = "test-only",
   };
   _EGLDisplay display = {.DriverData = &driver};
   mask = (1 << __DRI_API_GLES2) | (1 << __DRI_API_GLES3);
   if (mode == 12) {
      driver.driver_name = "another-driver";
      dri2_set_WL_bind_wayland_display(&display);
      assert(display.Extensions.WL_bind_wayland_display);
      assert(calls == 0);
      assert(munmap(opaque, 4096) == 0);
      puts("non-mtgpu WL_bind_wayland_display legacy behavior unchanged");
      return 0;
   }
   unsigned expected_calls = 1;
   if (mode == 1) {
      driver.image_driver = NULL;
      driver.dri2 = &dri2;
   } else if (mode == 2) {
      image_driver.getAPIMask = NULL;
      expected_calls = 0;
   } else if (mode == 3) {
      driver.image_driver = NULL;
      driver.dri2 = &dri2;
      dri2.base.version = 1;
      expected_calls = 0;
   } else if (mode == 4) {
      driver.driver_name = "another-driver";
   } else if (mode == 5) {
      mask = 0;
   } else if (mode == 6) {
      driver.fence = &fence;
   } else if (mode == 7) {
      image_driver.base.version = 0;
      expected_calls = 0;
   } else if (mode >= 8) {
      image.base.version = 20;
      if (mode == 9 || mode == 10)
         image.getCapabilities = global_names;
      if (mode == 9 || mode == 11) {
         image.createImageFromName = from_name;
         image.createImageFromNames = from_names;
         image.createImageFromFds = from_names;
      }
   }
   dri2_setup_screen(&display);
   assert(calls == expected_calls);
   assert(display.ClientAPIs == ((calls && mask) ?
          EGL_OPENGL_ES2_BIT | EGL_OPENGL_ES3_BIT_KHR : 0));
   assert(!display.Extensions.IMG_context_priority);
   assert(!display.Extensions.EXT_create_context_robustness);
   assert(!display.Extensions.KHR_gl_texture_3D_image);
   assert(!display.Extensions.EXT_protected_surface);
   assert(!display.Extensions.EXT_protected_content);
   assert(!display.Extensions.KHR_gl_colorspace);
   assert(!display.Extensions.EXT_pixel_format_float);
   assert(!display.Extensions.KHR_create_context_no_error);
   assert(!display.Extensions.ANDROID_native_fence_sync);
   assert(!display.Extensions.EXT_image_dma_buf_import_modifiers);
   assert(display.Extensions.MESA_drm_image == (mode == 9));
   dri2_set_WL_bind_wayland_display(&display);
   assert(display.Extensions.WL_bind_wayland_display == (mode == 9));
   assert(driver.min_swap_interval == 1 && driver.max_swap_interval == 1);
   assert(munmap(opaque, 4096) == 0);
   printf("opaque-screen case %d passed: public callback calls=%u\n", mode, calls);
   return 0;
}
