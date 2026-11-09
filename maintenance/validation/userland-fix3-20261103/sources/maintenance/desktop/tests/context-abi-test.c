/* Include the exact patched source to exercise its static dispatcher, not a
 * restatement of the implementation. Linker section GC removes unused EGL
 * entry points. No driver is loaded and no GPU operation occurs. */
#include "egl_dri2.c"
#include <sys/mman.h>

static __DRIscreen *screen_expected;
static const __DRIconfig *config_expected;
static __DRIcontext *shared_expected;
static void *loader_expected;
static const uint32_t attributes[] = {0, 2, 1, 0, 2, 1};
static unsigned calls, chosen;
static unsigned error_to_return = __DRI_CTX_ERROR_SUCCESS;

void _eglLog(EGLint level, const char *fmt, ...)
{
   (void)level;
   (void)fmt;
}

static __DRIcontext *
public_create(__DRIscreen *screen, int api, const __DRIconfig *config,
              __DRIcontext *shared, unsigned count, const uint32_t *attrs,
              unsigned *error, void *loader)
{
   assert(screen == screen_expected);
   assert(api == __DRI_API_GLES2);
   assert(config == config_expected && shared == shared_expected);
   assert(count == 3 && attrs == attributes);
   assert(!memcmp(attrs, attributes, sizeof attributes));
   assert(loader == loader_expected);
   ++calls;
   *error = error_to_return;
   return error_to_return == __DRI_CTX_ERROR_SUCCESS ? shared_expected : NULL;
}

static __DRIcontext *
mesa_create(__DRIscreen *screen, int api, const __DRIconfig *config,
            __DRIcontext *shared, unsigned count, const uint32_t *attrs,
            unsigned *error, void *loader)
{
   chosen = 1;
   return public_create(screen, api, config, shared, count, attrs, error, loader);
}

int main(void)
{
   void *page = mmap(NULL, 4096, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   assert(page != MAP_FAILED);
   screen_expected = page;
   config_expected = page;
   shared_expected = page;
   loader_expected = page;
   __DRIimageDriverExtension image = {
      .base = {__DRI_IMAGE_DRIVER, 1}, .createContextAttribs = public_create,
   };
   __DRIdri2Extension dri2 = {
      .base = {__DRI_DRI2, 4}, .createContextAttribs = public_create,
   };
   __DRImesaCoreExtension mesa = {
      .base = {__DRI_MESA, 1}, .createContext = NULL,
   };
   struct dri2_egl_display driver = {
      .driver_name = "mtgpu", .dri_screen_render_gpu = page,
      .image_driver = &image, .mesa = &mesa,
   };
   for (int mode = 0; mode < 8; ++mode) {
      calls = chosen = 0;
      driver.driver_name = "mtgpu";
      driver.image_driver = &image;
      image.base.version = 1;
      image.createContextAttribs = public_create;
      driver.dri2 = NULL;
      dri2.base.version = 4;
      mesa.createContext = NULL;
      error_to_return = __DRI_CTX_ERROR_SUCCESS;
      unsigned expected_calls = 1;
      if (mode == 1) {
         driver.image_driver = NULL;
         driver.dri2 = &dri2;
      } else if (mode == 2) {
         image.createContextAttribs = NULL;
         driver.dri2 = &dri2;
      } else if (mode == 3) {
         image.createContextAttribs = NULL;
         expected_calls = 0;
      } else if (mode == 4) {
         image.base.version = 0;
         expected_calls = 0;
      } else if (mode == 5) {
         driver.image_driver = NULL;
         driver.dri2 = &dri2;
         dri2.base.version = 2;
         expected_calls = 0;
      } else if (mode == 6) {
         error_to_return = __DRI_CTX_ERROR_BAD_VERSION;
      } else if (mode == 7) {
         driver.driver_name = "another-driver";
         mesa.createContext = mesa_create;
      }
      unsigned error = 12345;
      __DRIcontext *result = dri2_create_driver_context(
         &driver, __DRI_API_GLES2, config_expected, shared_expected,
         3, attributes, &error, loader_expected);
      assert(calls == expected_calls);
      assert(chosen == (mode == 7));
      assert(error == (expected_calls ? error_to_return : __DRI_CTX_ERROR_BAD_API));
      assert(result == ((expected_calls && error == __DRI_CTX_ERROR_SUCCESS) ?
                        shared_expected : NULL));
      printf("context ABI case %d passed: calls=%u error=%u\n", mode, calls, error);
   }
   assert(munmap(page, 4096) == 0);
   return 0;
}
