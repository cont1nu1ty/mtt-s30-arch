/* SPDX-License-Identifier: MIT
 * CPU-only lifetime regression for the pinned x86-64 Wayland swapchain.
 * Supply the same ownership layout as the core, with inert GPU references.
 * The addresses below apply only to the two hash-checked vendor ELF files.
 */
#define _GNU_SOURCE
#include <assert.h>
#include <dlfcn.h>
#include <link.h>
#include <sanitizer/asan_interface.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void store_pointer(unsigned char *storage, size_t offset, void *value)
{
    memcpy(storage + offset, &value, sizeof value);
}

int main(int argc, char **argv)
{
    if (argc != 4) return 2;
    bool deleting = strcmp(argv[2], "deleting") == 0;
    void *library = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    struct link_map *image = NULL;
    assert(library && dlinfo(library, RTLD_DI_LINKMAP, &image) == 0);
    if (strcmp(argv[2], "load-unload") == 0)
        return dlclose(library) == 0 ? 0 : 1;
    assert(deleting || strcmp(argv[2], "complete") == 0);
    size_t nodes = strtoul(argv[3], NULL, 10);
    assert(nodes == 1 || nodes == 3);
    typedef void (*destructor)(void *);
    destructor *vtable = (destructor *)(image->l_addr + 0x1070088);
    assert((uintptr_t)vtable[0] - image->l_addr == 0x5a5170);
    assert((uintptr_t)vtable[1] - image->l_addr == 0x5875b0);
    unsigned char *object = calloc(1, 0x240);
    void **map = calloc(8, sizeof *map);
    void *blocks[3] = {0};
    assert(object && map);
    store_pointer(object, 0, vtable);
    for (size_t i = 0; i < nodes; ++i) {
        blocks[i] = malloc(512);
        assert(blocks[i]);
        map[3 + i] = blocks[i];
    }
    /* std::deque map, map size, and start/end iterators in the base object.
     * The old destructor leaves the map slot intact after freeing its block.
     */
    store_pointer(object, 0x1e0, map);
    const size_t capacity = 8;
    memcpy(object + 0x1e8, &capacity, sizeof capacity);
    for (size_t i = 0; i < 2; ++i) {
        size_t node = i ? nodes - 1 : 0;
        size_t iter = 0x1f0 + 0x20 * i;
        store_pointer(object, iter, blocks[node]);
        store_pointer(object, iter + 8, blocks[node]);
        store_pointer(object, iter + 16, (unsigned char *)blocks[node] + 512);
        store_pointer(object, iter + 24, &map[3 + node]);
    }
    vtable[deleting ? 1 : 0](object);
    for (size_t i = 0; i < nodes; ++i)
        assert(__asan_address_is_poisoned(blocks[i]));
    assert(__asan_address_is_poisoned(map));
    assert(!!__asan_address_is_poisoned(object) == deleting);
    if (!deleting) free(object);
    /* Leave module globals live for LeakSanitizer's object-scope check.
     * A separate original/candidate control explicitly unloads each ELF.
     */
    printf("%s destructor released %zu block(s) and the map; object ownership correct\n", argv[2], nodes);
    return 0;
}
