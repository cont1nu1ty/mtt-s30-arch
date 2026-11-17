CC ?= gcc
override CFLAGS += -O2 -Wall -Wextra -Werror -fPIC -fvisibility=hidden
LIBS = -ldl -lpthread

ALL_LIBS = libEGL_mtgpu_guard.so libEGL_mtt_mesa_guard.so libVK_MT_guard.so

all: $(ALL_LIBS)

libEGL_mtgpu_guard.so: egl_guard.c mtgpu_guard_common.h
	$(CC) $(CFLAGS) -DGUARD_TARGET_PATH='"/usr/lib/libEGL_mtgpu.so.0"' egl_guard.c -o $@ -shared $(LDFLAGS) $(LIBS)

libEGL_mtt_mesa_guard.so: egl_guard.c mtgpu_guard_common.h
	$(CC) $(CFLAGS) -DGUARD_TARGET_PATH='"/usr/lib/mthreads/egl/libEGL_mesa.so.0"' egl_guard.c -o $@ -shared $(LDFLAGS) $(LIBS)

libVK_MT_guard.so: vk_guard.c mtgpu_guard_common.h
	$(CC) $(CFLAGS) -DGUARD_VK_TARGET_PATH='"/usr/lib/libVK_MT.so"' vk_guard.c -o $@ -shared $(LDFLAGS) $(LIBS)

clean:
	rm -f $(ALL_LIBS)
