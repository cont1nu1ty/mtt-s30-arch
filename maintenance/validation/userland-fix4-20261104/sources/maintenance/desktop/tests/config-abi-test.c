/* Replay opaque config bytes copied from a crash core. The vendor's public
 * attribute getters only read scalar fields. No screen/context is created.
 * Call the actual private EGL library's config conversion and validation. */
#include "egl_dri2.h"
#include <assert.h>
#include <dlfcn.h>
#include <link.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const __DRIcoreExtension *vendor_core;
static const char *mode;

static int index_config(const __DRIconfig *config, int index,
                        unsigned *attribute, unsigned *value)
{
   if (!strcmp(mode, "filtered")) {
      int retained = 0;
      for (int i = 0; i < 256; ++i) {
         if (!vendor_core->indexConfigAttrib(config, i, attribute, value))
            return 0;
         if (*attribute >= __DRI_ATTRIB_MAX)
            continue;
         if (retained++ == index)
            return 1;
      }
      abort();
   }
   int result = vendor_core->indexConfigAttrib(config, index, attribute, value);
   if (result && !strcmp(mode, "max") && *attribute >= __DRI_ATTRIB_MAX)
      *attribute = UINT32_MAX;
   if (result && !strcmp(mode, "invalid-render") && *attribute == __DRI_ATTRIB_RENDER_TYPE)
      *value = 0;
   if (result && !strcmp(mode, "invalid-depth") && *attribute == __DRI_ATTRIB_DEPTH_SIZE)
      *value = UINT32_MAX;
   return result;
}

static unsigned get(const __DRIconfig *config, unsigned attr)
{
   unsigned value = 0;
   assert(vendor_core->getConfigAttrib(config, attr, &value));
   return value;
}

int main(int argc, char **argv)
{
   assert(argc == 6);
   const char *egl_path = argv[1], *vendor_path = argv[3];
   uintptr_t offset = strtoull(argv[2], NULL, 16);
   mode = argv[5];
   FILE *input = fopen(argv[4], "rb");
   assert(input);
   uint32_t shape[2];
   assert(fread(shape, sizeof shape, 1, input) == 1);
   assert(shape[0] > 0 && shape[0] <= 512 && shape[1] == 212);
   unsigned char *configs = malloc((size_t)shape[0] * shape[1]);
   assert(configs && fread(configs, shape[1], shape[0], input) == shape[0]);
   assert(fgetc(input) == EOF);
   fclose(input);

   void *egl = dlopen(egl_path, RTLD_NOW | RTLD_LOCAL);
   if (!egl) { fprintf(stderr, "%s\n", dlerror()); return 3; }
   struct link_map *map = NULL;
   assert(!dlinfo(egl, RTLD_DI_LINKMAP, &map) && map);
   struct dri2_egl_config *(*add_config)(_EGLDisplay *, const __DRIconfig *,
      int, EGLint, const EGLint *, const int *, const unsigned int *) =
      (void *)(map->l_addr + offset);
   void *vendor = dlopen(vendor_path, RTLD_NOW | RTLD_LOCAL);
   if (!vendor) { fprintf(stderr, "%s\n", dlerror()); return 3; }
   const __DRIextension **(*extensions)(void) =
      dlsym(vendor, "__driDriverGetExtensions_mtgpu");
   assert(extensions);
   const __DRIextension **table = extensions();
   for (unsigned i = 0; table[i]; ++i)
      if (!strcmp(table[i]->name, __DRI_CORE))
         vendor_core = (const __DRIcoreExtension *)table[i];
   assert(vendor_core && vendor_core->getConfigAttrib && vendor_core->indexConfigAttrib);
   __DRIcoreExtension wrapped = *vendor_core;
   wrapped.indexConfigAttrib = index_config;

   unsigned accepted = 0;
   for (unsigned i = 0; i < shape[0]; ++i) {
      const __DRIconfig *config = (const void *)(configs + i * shape[1]);
      struct dri2_egl_display driver = {
         .core = &wrapped, .driver_name = "mtgpu",
         .min_swap_interval = 1, .max_swap_interval = 1,
      };
      _EGLDisplay display = {
         .DriverData = &driver,
         .ClientAPIs = EGL_OPENGL_BIT | EGL_OPENGL_ES2_BIT | EGL_OPENGL_ES3_BIT_KHR,
      };
      int shifts[4] = {
         get(config, __DRI_ATTRIB_RED_SHIFT), get(config, __DRI_ATTRIB_GREEN_SHIFT),
         get(config, __DRI_ATTRIB_BLUE_SHIFT), get(config, __DRI_ATTRIB_ALPHA_SHIFT),
      };
      unsigned sizes[4] = {
         get(config, __DRI_ATTRIB_RED_SIZE), get(config, __DRI_ATTRIB_GREEN_SIZE),
         get(config, __DRI_ATTRIB_BLUE_SIZE), get(config, __DRI_ATTRIB_ALPHA_SIZE),
      };
      const EGLint invalid_attributes[] = {0x12345, 0, EGL_NONE};
      const EGLint *attrs = !strcmp(mode, "invalid-key") ? invalid_attributes : NULL;
      struct dri2_egl_config *converted = add_config(
         &display, config, i + 1, EGL_WINDOW_BIT, attrs, shifts, sizes);
      bool invalid = !strcmp(mode, "invalid-render") || !strcmp(mode, "invalid-depth");
      bool expected = !invalid && get(config, __DRI_ATTRIB_DOUBLE_BUFFER) &&
                      !get(config, __DRI_ATTRIB_FRAMEBUFFER_SRGB_CAPABLE);
      assert((converted != NULL) == expected);
      if (!converted) {
         printf("config %u rejected\n", i);
         continue;
      }
      ++accepted;
      assert(converted->base.ColorBufferType == EGL_RGB_BUFFER);
      assert(converted->base.RenderableType == display.ClientAPIs);
      assert(converted->base.Conformant == display.ClientAPIs);
      assert(converted->base.SurfaceType == EGL_WINDOW_BIT);
      assert(converted->dri_config[1][0] == config);
      assert(converted->base.RedSize == (int)sizes[0]);
      assert(converted->base.GreenSize == (int)sizes[1]);
      assert(converted->base.BlueSize == (int)sizes[2]);
      assert(converted->base.AlphaSize == (int)sizes[3]);
      assert(converted->base.DepthSize == (int)get(config, __DRI_ATTRIB_DEPTH_SIZE));
      assert(converted->base.StencilSize == (int)get(config, __DRI_ATTRIB_STENCIL_SIZE));
      assert(converted->base.Samples == (int)get(config, __DRI_ATTRIB_SAMPLES));
      printf("config %u accepted rgba=%d,%d,%d,%d depth=%d stencil=%d samples=%d color=%d caveat=%d api=%d\n",
             i, converted->base.RedSize, converted->base.GreenSize,
             converted->base.BlueSize, converted->base.AlphaSize,
             converted->base.DepthSize, converted->base.StencilSize,
             converted->base.Samples, converted->base.ColorBufferType,
             converted->base.ConfigCaveat, converted->base.RenderableType);
   }
   printf("accepted=%u total=%u\n", accepted, shape[0]);
   free(configs);
   return 0;
}
