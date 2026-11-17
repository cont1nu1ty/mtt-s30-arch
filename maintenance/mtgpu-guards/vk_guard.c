/* SPDX-License-Identifier: MIT */
#include <stdint.h>
#include "mtgpu_guard_common.h"

#ifndef GUARD_VK_TARGET_PATH
#define GUARD_VK_TARGET_PATH "/usr/lib/libVK_MT.so"
#endif

typedef int32_t VkResult;
typedef uint32_t VkFlags;
typedef void *VkInstance;
typedef void (*PFN_vkVoidFunction)(void);

#define VK_SUCCESS ((VkResult)0)
#define VK_ERROR_OUT_OF_HOST_MEMORY ((VkResult)-1)
#define VK_ERROR_INITIALIZATION_FAILED ((VkResult)-3)
#define ICD_LOADER_MAGIC 0x01CDC0DEU

typedef VkResult (*PFN_vk_icdNegotiate)(uint32_t *pVersion);
typedef PFN_vkVoidFunction (*PFN_vk_getProc)(VkInstance instance, const char *pName);
typedef VkResult (*PFN_vk_enumExt)(const char *pLayerName, uint32_t *pPropertyCount, void *pProperties);

struct mtgpu_stub_vk_instance {
    uintptr_t loader_magic;
};

static pthread_mutex_t g_vk_lock = PTHREAD_MUTEX_INITIALIZER;
static void *g_vk_handle = NULL;
static PFN_vk_icdNegotiate g_real_negotiate = NULL;
static PFN_vk_getProc g_real_icd_get_proc = NULL;
static PFN_vk_getProc g_real_get_proc = NULL;
static PFN_vk_enumExt g_real_enum_ext = NULL;

static int mtgpu_vk_ensure_loaded(PFN_vk_icdNegotiate *neg,
                                  PFN_vk_getProc *icd_get,
                                  PFN_vk_getProc *get,
                                  PFN_vk_enumExt *enum_ext)
{
    int ok = 0;

    if (!mtgpu_guard_is_active())
        return 0;

    pthread_mutex_lock(&g_vk_lock);
    if (!g_vk_handle) {
        void *h = dlopen(GUARD_VK_TARGET_PATH, RTLD_LAZY | RTLD_LOCAL);
        if (h) {
            g_real_negotiate = (PFN_vk_icdNegotiate)dlsym(h, "vk_icdNegotiateLoaderICDInterfaceVersion");
            g_real_icd_get_proc = (PFN_vk_getProc)dlsym(h, "vk_icdGetInstanceProcAddr");
            g_real_get_proc = (PFN_vk_getProc)dlsym(h, "vkGetInstanceProcAddr");
            g_real_enum_ext = (PFN_vk_enumExt)dlsym(h, "vkEnumerateInstanceExtensionProperties");
            g_vk_handle = h;
        }
    }
    if (g_vk_handle) {
        if (neg) *neg = g_real_negotiate;
        if (icd_get) *icd_get = g_real_icd_get_proc;
        if (get) *get = g_real_get_proc;
        if (enum_ext) *enum_ext = g_real_enum_ext;
        ok = 1;
    }
    pthread_mutex_unlock(&g_vk_lock);
    return ok;
}

static VkResult stub_vkCreateInstance(const void *pCreateInfo,
                                      const void *pAllocator,
                                      VkInstance *pInstance)
{
    struct mtgpu_stub_vk_instance *inst;
    (void)pCreateInfo;
    (void)pAllocator;
    if (!pInstance)
        return VK_ERROR_INITIALIZATION_FAILED;
    inst = calloc(1, sizeof(*inst));
    if (!inst)
        return VK_ERROR_OUT_OF_HOST_MEMORY;
    inst->loader_magic = ICD_LOADER_MAGIC;
    *pInstance = inst;
    return VK_SUCCESS;
}

static void stub_vkDestroyInstance(VkInstance instance, const void *pAllocator)
{
    (void)pAllocator;
    free(instance);
}

static VkResult stub_vkEnumeratePhysicalDevices(VkInstance instance,
                                                uint32_t *pPhysicalDeviceCount,
                                                void *pPhysicalDevices)
{
    (void)instance;
    (void)pPhysicalDevices;
    if (pPhysicalDeviceCount)
        *pPhysicalDeviceCount = 0;
    return VK_SUCCESS;
}

static PFN_vkVoidFunction stub_lookup(const char *pName);

VkResult vkEnumerateInstanceExtensionProperties(const char *pLayerName,
                                                uint32_t *pPropertyCount,
                                                void *pProperties);

static PFN_vkVoidFunction stub_lookup(const char *pName)
{
    if (!pName)
        return NULL;
    if (strcmp(pName, "vkCreateInstance") == 0)
        return (PFN_vkVoidFunction)stub_vkCreateInstance;
    if (strcmp(pName, "vkDestroyInstance") == 0)
        return (PFN_vkVoidFunction)stub_vkDestroyInstance;
    if (strcmp(pName, "vkEnumeratePhysicalDevices") == 0)
        return (PFN_vkVoidFunction)stub_vkEnumeratePhysicalDevices;
    if (strcmp(pName, "vkEnumerateInstanceExtensionProperties") == 0)
        return (PFN_vkVoidFunction)vkEnumerateInstanceExtensionProperties;
    return NULL;
}

__attribute__((visibility("default")))
VkResult vk_icdNegotiateLoaderICDInterfaceVersion(uint32_t *pVersion)
{
    PFN_vk_icdNegotiate real_fn = NULL;

    if (mtgpu_vk_ensure_loaded(&real_fn, NULL, NULL, NULL) && real_fn)
        return real_fn(pVersion);

    if (pVersion && *pVersion > 5)
        *pVersion = 5;
    return VK_SUCCESS;
}

__attribute__((visibility("default")))
PFN_vkVoidFunction vk_icdGetInstanceProcAddr(VkInstance instance, const char *pName)
{
    PFN_vk_getProc real_fn = NULL;

    if (mtgpu_vk_ensure_loaded(NULL, &real_fn, NULL, NULL) && real_fn)
        return real_fn(instance, pName);

    return stub_lookup(pName);
}

__attribute__((visibility("default")))
PFN_vkVoidFunction vkGetInstanceProcAddr(VkInstance instance, const char *pName)
{
    PFN_vk_getProc real_fn = NULL;

    if (mtgpu_vk_ensure_loaded(NULL, NULL, &real_fn, NULL) && real_fn)
        return real_fn(instance, pName);

    return stub_lookup(pName);
}

__attribute__((visibility("default")))
VkResult vkEnumerateInstanceExtensionProperties(const char *pLayerName,
                                                uint32_t *pPropertyCount,
                                                void *pProperties)
{
    PFN_vk_enumExt real_fn = NULL;

    if (mtgpu_vk_ensure_loaded(NULL, NULL, NULL, &real_fn) && real_fn)
        return real_fn(pLayerName, pPropertyCount, pProperties);

    (void)pLayerName;
    (void)pProperties;
    if (pPropertyCount)
        *pPropertyCount = 0;
    return VK_SUCCESS;
}
