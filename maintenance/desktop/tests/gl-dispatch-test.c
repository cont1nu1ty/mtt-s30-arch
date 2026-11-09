/* SPDX-License-Identifier: MIT
 * Exercise the real EGL vendor ABI and two real GL dispatchers. Only the
 * functions installed into the TLS dispatch tables are CPU test fixtures.
 */
#define _GNU_SOURCE
#include <assert.h>
#include <dlfcn.h>
#include <glvnd/libeglabi.h>
#include <GLES3/gl3.h>
#include <inttypes.h>
#include <link.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct provider {
    void *(*lookup)(const char *);
    int (*offset)(const char *);
    unsigned (*size)(void);
    void (*bind)(void **);
};
struct entries {
    const GLubyte *(*identity)(GLenum);
    GLuint (*shader)(GLenum);
    void (*uniform)(GLint, GLint);
    void (*internal_flush)(void);
};
static _Thread_local int uniform_value, flush_count;
static const GLubyte *identity_a(GLenum name) {
    assert(name == GL_RENDERER || name == GL_VENDOR);
    return (const GLubyte *)(name == GL_RENDERER ? "sentinel-A" : "fixture vendor");
}
static const GLubyte *identity_b(GLenum name) {
    assert(name == GL_RENDERER || name == GL_VENDOR);
    return (const GLubyte *)(name == GL_RENDERER ? "sentinel-B" : "fixture vendor");
}
static GLuint shader(GLenum type) { assert(type == GL_FRAGMENT_SHADER); return 0x1a3; }
static void uniform(GLint loc, GLint value) { assert(loc == 3); uniform_value = value; }
static void flush(void) { ++flush_count; }

static void *load(const char *path) {
    void *handle = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!handle) fprintf(stderr, "%s: %s\n", path, dlerror());
    assert(handle);
    return handle;
}
static void *symbol(void *handle, const char *prefix, const char *suffix) {
    char name[96];
    assert(snprintf(name, sizeof(name), "%s%s", prefix, suffix) < (int)sizeof(name));
    void *p = dlsym(handle, name);
    if (!p) fprintf(stderr, "Missing symbol %s\n", name);
    assert(p);
    return p;
}
static struct provider open_provider(const char *path, const char *prefix) {
    void *h = load(path);
    return (struct provider){
        symbol(h, prefix, "get_proc_address"), symbol(h, prefix, "get_proc_offset"),
        symbol(h, prefix, "get_dispatch_table_size"), symbol(h, prefix, "set_dispatch")};
}
static void fill(struct provider p, void **table, const char *name, void *function) {
    int offset = p.offset(name);
    assert(offset >= 0 && (unsigned)offset < p.size());
    table[offset] = function;
}
static void **table(struct provider p, void *identity) {
    void **values = calloc(p.size(), sizeof(*values));
    assert(values);
    fill(p, values, "glGetString", identity);
    fill(p, values, "glCreateShader", shader);
    fill(p, values, "glUniform1i", uniform);
    fill(p, values, "glFlush", flush);
    return values;
}
static void check(struct entries e, const char *expected) {
    assert(!strcmp((const char *)e.identity(GL_RENDERER), expected));
    assert(!strcmp((const char *)e.identity(GL_VENDOR), "fixture vendor"));
    assert(e.shader(GL_FRAGMENT_SHADER) == 0x1a3);
    uniform_value = 0;
    e.uniform(3, -231);
    assert(uniform_value == -231);
    int previous = flush_count;
    e.internal_flush();
    assert(flush_count == previous + 1);
}
struct worker_state {
    struct entries e;
    struct provider p;
    void **dispatch;
    pthread_barrier_t barrier;
};
static void rendezvous(pthread_barrier_t *barrier) {
    int error = pthread_barrier_wait(barrier);
    assert(!error || error == PTHREAD_BARRIER_SERIAL_THREAD);
}
static void *worker(void *arg) {
    struct worker_state *s = arg;
    assert(s->e.identity(GL_RENDERER) == NULL);
    s->p.bind(s->dispatch);
    rendezvous(&s->barrier);
    check(s->e, "sentinel-B");
    rendezvous(&s->barrier);
    s->p.bind(NULL);
    assert(s->e.identity(GL_RENDERER) == NULL);
    return NULL;
}

int main(int argc, char **argv) {
    /* mode, EGL, ordinary GLAPI, vendor GLAPI, linked flush-get address, GL names */
    assert(argc >= 7);
    const char *mode = argv[1];
    void *egl = load(argv[2]);
    __PFNEGLMAINPROC initialize = symbol(egl, "", __EGL_MAIN_PROTO_NAME);
    const __EGLapiExports exports = {0};
    __EGLapiImports imports = {0};
    assert(initialize(EGL_VENDOR_ABI_VERSION, &exports, NULL, &imports));
    assert(imports.getProcAddress("eglQueryString"));
    assert(imports.getProcAddress("eglGetError"));
    /* GLVND may request and cache these before a DRI context is bound. */
    struct entries e = {.identity = imports.getProcAddress("glGetString"),
        .shader = imports.getProcAddress("glCreateShader"),
        .uniform = imports.getProcAddress("glUniform1i")};
    struct link_map *map;
    assert(dlinfo(egl, RTLD_DI_LINKMAP, &map) == 0);
    uintptr_t offset = strtoumax(argv[5], NULL, 16);
    assert(offset > 0);
    void (*flush_get)(void (**)(void)) = (void *)(map->l_addr + offset);
    flush_get(&e.internal_flush);
    if (!strcmp(mode, "unavailable")) {
        assert(!e.identity && !e.shader && !e.uniform && !e.internal_flush);
        assert(imports.getProcAddress("eglGetError"));
        puts("Unavailable opt-in provider rejected with EGL entry points intact.");
        return 0;
    }
    assert(e.identity && e.shader && e.uniform && e.internal_flush);
    struct provider mesa = open_provider(argv[3], "_glapi_");
    struct provider musa = open_provider(argv[4], "musa_glapi_");
    mesa.bind(NULL);
    musa.bind(NULL);
    struct provider expected = !strcmp(mode, "vendor") ? musa : mesa;
    for (int i = 6; i < argc; ++i) {
        void *actual = imports.getProcAddress(argv[i]);
        assert(actual && actual == expected.lookup(argv[i]));
    }
    assert((void *)e.internal_flush == expected.lookup("glFlush"));
    if (!strcmp(mode, "baseline")) {
        void **b = table(musa, identity_b);
        musa.bind(b);
        assert(((const GLubyte *(*)(GLenum))musa.lookup("glGetString"))(GL_RENDERER));
        assert(!e.identity(GL_RENDERER) && !e.identity(GL_VENDOR));
        musa.bind(NULL);
        free(b);
        puts("v8 negative control: vendor-only bound table, cached EGL GL entries return NULL.");
        return 0;
    }
    struct provider other = !strcmp(mode, "vendor") ? mesa : musa;
    void **a = table(expected, identity_a), **b = table(expected, identity_b);
    void **distractor = table(other, identity_b);
    other.bind(distractor);
    assert(!e.identity(GL_RENDERER));
    expected.bind(a);
    check(e, "sentinel-A");
    struct worker_state s = {.e = e, .p = expected, .dispatch = b};
    assert(!pthread_barrier_init(&s.barrier, NULL, 2));
    pthread_t thread;
    assert(!pthread_create(&thread, NULL, worker, &s));
    rendezvous(&s.barrier);
    check(e, "sentinel-A");
    rendezvous(&s.barrier);
    assert(!pthread_join(thread, NULL));
    assert(!pthread_barrier_destroy(&s.barrier));
    expected.bind(b);
    check(e, "sentinel-B");
    expected.bind(NULL);
    assert(!e.identity(GL_RENDERER));
    other.bind(NULL);
    free(a); free(b); free(distractor);
    printf("%s: %d client entries, internal flush, pre-bind, rebind, unbind, thread isolation passed.\n", mode, argc - 6);
    return 0;
}
