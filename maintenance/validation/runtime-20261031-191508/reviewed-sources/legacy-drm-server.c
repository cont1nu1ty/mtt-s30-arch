/* Diagnostic protocol fixture. The advertised path intentionally does not
 * exist; this process never opens a GPU or handles real buffers. */
#include <wayland-server.h>
#include <stdio.h>
#include <string.h>
#include "wayland-drm-server.h"

static void authenticate(struct wl_client *c, struct wl_resource *r, uint32_t magic)
{ (void)c; (void)magic; wl_resource_post_error(r, WL_DRM_ERROR_AUTHENTICATE_FAIL, "fixture rejects authentication"); }
static const struct wl_drm_interface implementation = { .authenticate = authenticate };
static void bind_drm(struct wl_client *c, void *data, uint32_t version, uint32_t id)
{
    (void)data;
    struct wl_resource *r = wl_resource_create(c, &wl_drm_interface, version > 2 ? 2 : version, id);
    wl_resource_set_implementation(r, &implementation, NULL, NULL);
    wl_drm_send_device(r, "/dev/mtt-s30-protocol-fixture-does-not-exist");
    wl_drm_send_format(r, WL_DRM_FORMAT_XRGB8888);
    wl_drm_send_format(r, WL_DRM_FORMAT_ARGB8888);
    if (version >= 2) wl_drm_send_capabilities(r, WL_DRM_CAPABILITY_PRIME);
}
int main(int argc, char **argv)
{
    struct wl_display *d = wl_display_create();
    if (!d || argc != 2) return 2;
    if (!strcmp(argv[1], "legacy")) wl_global_create(d, &wl_drm_interface, 2, NULL, bind_drm);
    if (wl_display_add_socket(d, "egl-fixture") != 0) return 2;
    puts("ready"); fflush(stdout);
    wl_display_run(d);
    wl_display_destroy(d);
    return 0;
}
