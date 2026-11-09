/* Exercise the real private EGL library's screen factory, image lookup,
 * resource validation/locking, and screen teardown.  Only createNewScreen and
 * destroyScreen are fixture callbacks: no real driver or GPU is initialized.
 */
#include "egl_dri2.h"
#include <assert.h>
#include <dlfcn.h>
#include <link.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

static _EGLDisplay *expected_display;
static void *expected_native;
static void *captured_private;
static __DRIscreen *opaque_screen;
static bool expect_bridge;
static bool screen_failure;
static unsigned create_calls, destroy_calls;

static void check_private(void)
{
   assert(captured_private);
   if (expect_bridge) {
      assert(captured_private != expected_display);
      uint32_t platform;
      void *native;
      memcpy(&platform, (char *)captured_private + 0x30, sizeof platform);
      memcpy(&native, (char *)captured_private + 0x38, sizeof native);
      assert(platform == _EGL_PLATFORM_WAYLAND);
      assert(native == expected_native);
   } else {
      assert(captured_private == expected_display);
   }
}

static __DRIscreen *screen_factory(int index, int fd,
                                  const __DRIextension **loaders,
                                  const __DRIextension **drivers,
                                  const __DRIconfig ***configs, void *data)
{
   (void)loaders;
   (void)drivers;
   assert(index == 0 && fd == -1);
   ++create_calls;
   captured_private = data;
   check_private();
   if (screen_failure)
      return NULL;
   *configs = calloc(1, sizeof **configs);
   assert(*configs);
   return opaque_screen;
}

static void destroy_screen(__DRIscreen *screen)
{
   assert(screen == opaque_screen);
   ++destroy_calls;
   /* The bridge must still be live when the driver destroys its screen. */
   check_private();
   assert(expected_display->DriverData);
}

int main(int argc, char **argv)
{
   assert(argc == 13);
   const char *mode = argv[2];
   const bool baseline = !strcmp(mode, "baseline");
   const bool non_mtgpu = !strcmp(mode, "other-driver");
   const bool non_wayland = !strcmp(mode, "other-platform");
   const bool null_driver = !strcmp(mode, "null-driver");
   screen_failure = !strcmp(mode, "create-failure");
   expect_bridge = !(baseline || non_mtgpu || non_wayland || null_driver);
   void *egl = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
   if (!egl) {
      fprintf(stderr, "%s\n", dlerror());
      return 3;
   }
   struct link_map *map = NULL;
   assert(!dlinfo(egl, RTLD_DI_LINKMAP, &map) && map);
#define AT(n) ((void *)(map->l_addr + strtoull(argv[n], NULL, 16)))
   _EGLDisplay *(*find_display)(_EGLPlatformType, void *, const EGLAttrib *) = AT(3);
   EGLBoolean (*create_screen)(_EGLDisplay *) = AT(4);
   void (*destroy_display)(_EGLDisplay *) = AT(5);
   void (*init_resource)(_EGLResource *, EGLint, _EGLDisplay *) = AT(6);
   void (*link_resource)(_EGLResource *, _EGLResourceType) = AT(7);
   void (*unlink_resource)(_EGLResource *, _EGLResourceType) = AT(8);
   _EGLDisplay *(*lock_display)(EGLDisplay) = AT(9);
   void (*unlock_display)(_EGLDisplay *) = AT(10);
   const __DRIimageLookupExtension *lookup = AT(11);
   EGLint (*get_error)(void) = AT(12);
#undef AT
   assert(lookup->base.version == 1);
   assert(lookup->lookupEGLImage);
   opaque_screen = mmap(NULL, 4096, PROT_NONE,
                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   assert(opaque_screen != MAP_FAILED);
   expected_native = opaque_screen;
   _EGLPlatformType platform = non_wayland ? _EGL_PLATFORM_X11 : _EGL_PLATFORM_WAYLAND;
   expected_display = find_display(platform, expected_native, NULL);
   assert(expected_display);
   expected_display->Initialized = EGL_TRUE;
   struct dri2_egl_display *driver = calloc(1, sizeof *driver);
   assert(driver);
   __DRImesaCoreExtension mesa = {
      .base = {__DRI_MESA, 1}, .createNewScreen = screen_factory,
   };
   __DRIcoreExtension core = {
      .base = {__DRI_CORE, 1}, .destroyScreen = destroy_screen,
   };
   driver->driver_name = null_driver ? NULL : strdup(non_mtgpu ? "another-driver" : "mtgpu");
   driver->fd_render_gpu = driver->fd_display_gpu = -1;
   driver->mesa = &mesa;
   driver->core = &core;
   expected_display->DriverData = driver;
   /* Copy the real display before bridge creation.  Its mutex and every
    * original field must remain unchanged by the compatibility adapter. */
   _EGLDisplay before = *expected_display;
   assert(create_screen(expected_display) == !screen_failure);
   assert(create_calls == 1);
   assert(!memcmp(&before, expected_display, sizeof before));
   assert(driver->own_dri_screen == !screen_failure);
   if (baseline) {
      uint32_t old_platform;
      memcpy(&old_platform, (char *)captured_private + 0x30, sizeof old_platform);
      assert(old_platform != _EGL_PLATFORM_WAYLAND);
      printf("baseline vendor-offset platform=%u actual=%u\n", old_platform,
             expected_display->Platform);
   }
   if (expect_bridge && !screen_failure) {
      struct dri2_egl_image image;
      init_resource(&image.base.Resource, sizeof image, expected_display);
      image.dri_image = (void *)opaque_screen;
      assert(lock_display(expected_display) == expected_display);
      link_resource(&image.base.Resource, _EGL_RESOURCE_IMAGE);
      unlock_display(expected_display);
      assert(lookup->lookupEGLImage(opaque_screen, &image, captured_private) == image.dri_image);
      assert(get_error() == EGL_SUCCESS);
      /* Invalid handles must go through the real EGL resource validator,
       * which rejects an unreadable handle without dereferencing it. */
      assert(!lookup->lookupEGLImage(opaque_screen, opaque_screen, captured_private));
      assert(get_error() == EGL_BAD_PARAMETER);
      assert(!lookup->lookupEGLImage(opaque_screen, NULL, captured_private));
      assert(get_error() == EGL_BAD_PARAMETER);
      assert(lock_display(expected_display) == expected_display);
      unlink_resource(&image.base.Resource, _EGL_RESOURCE_IMAGE);
      unlock_display(expected_display);
      assert(!lookup->lookupEGLImage(opaque_screen, &image, captured_private));
      assert(get_error() == EGL_BAD_PARAMETER);
      if (!strcmp(mode, "cross-display")) {
         _EGLDisplay *other = find_display(_EGL_PLATFORM_WAYLAND, (char *)opaque_screen + 16, NULL);
         assert(other && other != expected_display);
         other->Initialized = EGL_TRUE;
         init_resource(&image.base.Resource, sizeof image, other);
         image.dri_image = (void *)opaque_screen;
         assert(lock_display(other) == other);
         link_resource(&image.base.Resource, _EGL_RESOURCE_IMAGE);
         unlock_display(other);
         assert(!lookup->lookupEGLImage(opaque_screen, &image, captured_private));
         assert(get_error() == EGL_BAD_PARAMETER);
         assert(lock_display(other) == other);
         unlink_resource(&image.base.Resource, _EGL_RESOURCE_IMAGE);
         unlock_display(other);
         other->Initialized = EGL_FALSE;
      }
      if (!strcmp(mode, "invalid-bridge")) {
         assert(lock_display(expected_display) == expected_display);
         link_resource(&image.base.Resource, _EGL_RESOURCE_IMAGE);
         unlock_display(expected_display);
         assert(lookup->lookupEGLImage(opaque_screen, &image, captured_private) == image.dri_image);
         /* A copied bridge must not acquire the real display's lock or pass
          * identity validation merely because it contains its pointer. */
         uint64_t copy[9];
         memcpy(copy, captured_private, sizeof copy);
         assert(!lookup->lookupEGLImage(opaque_screen, &image, copy));
         assert(get_error() == EGL_BAD_PARAMETER);
         assert(!lookup->lookupEGLImage(opaque_screen, &image, NULL));
         assert(get_error() == EGL_BAD_PARAMETER);
         uint32_t original_platform;
         memcpy(&original_platform, (char *)captured_private + 0x30, sizeof original_platform);
         uint32_t invalid_platform = _EGL_PLATFORM_X11;
         memcpy((char *)captured_private + 0x30, &invalid_platform, sizeof invalid_platform);
         assert(!lookup->lookupEGLImage(opaque_screen, &image, captured_private));
         assert(get_error() == EGL_BAD_PARAMETER);
         memcpy((char *)captured_private + 0x30, &original_platform, sizeof original_platform);
         char *original_driver = driver->driver_name;
         driver->driver_name = NULL;
         assert(!lookup->lookupEGLImage(opaque_screen, &image, captured_private));
         assert(get_error() == EGL_BAD_PARAMETER);
         driver->driver_name = original_driver;
         assert(lookup->lookupEGLImage(opaque_screen, &image, captured_private) == image.dri_image);
         assert(get_error() == EGL_SUCCESS);
         assert(lock_display(expected_display) == expected_display);
         unlink_resource(&image.base.Resource, _EGL_RESOURCE_IMAGE);
         unlock_display(expected_display);
      }
   }
   destroy_display(expected_display);
   assert(destroy_calls == !screen_failure);
   assert(!expected_display->DriverData);
   expected_display->Initialized = EGL_FALSE;
   assert(!munmap(opaque_screen, 4096));
   printf("display bridge case %s passed: create=%u destroy=%u bridge=%u\n",
          mode, create_calls, destroy_calls, expect_bridge);
   return 0;
}
