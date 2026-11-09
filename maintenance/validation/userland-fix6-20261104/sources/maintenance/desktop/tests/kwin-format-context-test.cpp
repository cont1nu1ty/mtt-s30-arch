/* Actual EglDisplay constructor, query loop, cache intersection and refresh.
 * Only EGL/GL queries and the opaque DrmDevice identity are fixtures. No
 * context is created, no GPU node is opened, and no QGuiApplication is used.
 */
#include "opengl/egldisplay.h"
#include "core/drmdevice.h"

#include <algorithm>
#include <cassert>
#include <cstring>
#include <iostream>
#include <string>
#include <QLoggingCategory>

// The normal category is hidden inside libkwin; keep its production settings.
Q_LOGGING_CATEGORY(KWIN_OPENGL, "kwin_scene_opengl", QtWarningMsg)

using namespace KWin;

static const ::EGLDisplay expectedDisplay = reinterpret_cast<::EGLDisplay>(uintptr_t(0x1000));
static std::string scenario;
static bool currentPhase;
static int currentQueries, formatQueries, modifierQueries;
static bool terminated;

QByteArray DrmDevice::driverName() const
{
    assert(this == reinterpret_cast<const DrmDevice *>(uintptr_t(0x2000)));
    return scenario == "other-driver" ? QByteArrayLiteral("amdgpu") : QByteArrayLiteral("mtgpu");
}

static const char *EGLAPIENTRY queryString(::EGLDisplay display, EGLint key)
{
    if (display == EGL_NO_DISPLAY) {
        assert(key == EGL_EXTENSIONS);
        return ""; // Do not enable device discovery or open a DRM node.
    }
    assert(display == expectedDisplay);
    return key == EGL_VENDOR ? "MTT Mesa Client" : "";
}

static ::EGLDisplay EGLAPIENTRY currentDisplay()
{
    ++currentQueries;
    return scenario == "wrong-display" ? EGL_NO_DISPLAY : expectedDisplay;
}

static ::EGLContext EGLAPIENTRY currentContext()
{
    ++currentQueries;
    return scenario == "no-context" ? EGL_NO_CONTEXT : reinterpret_cast<::EGLContext>(uintptr_t(0x3000));
}

static const GLubyte *GLAPIENTRY renderer(GLenum name)
{
    assert(name == GL_RENDERER);
    if (scenario == "null-renderer") {
        return nullptr;
    }
    return reinterpret_cast<const GLubyte *>(scenario == "other-model" ? "MTT S80" : "MTT S30");
}

static EGLint EGLAPIENTRY getError()
{
    return EGL_SUCCESS;
}

static EGLBoolean EGLAPIENTRY terminate(::EGLDisplay display)
{
    assert(display == expectedDisplay);
    terminated = true;
    return EGL_TRUE;
}

static EGLBoolean EGLAPIENTRY queryFormats(::EGLDisplay display, EGLint max, EGLint *out, EGLint *count)
{
    assert(display == expectedDisplay && count && max >= 0);
    if (currentPhase) {
        ++formatQueries;
        if (scenario == (max ? "format-list-failure" : "format-count-failure")) {
            return EGL_FALSE;
        }
        if (!max && scenario == "format-count-overflow") {
            *count = 4097;
            return EGL_TRUE;
        }
        if (scenario == (max ? "format-list-negative" : "format-count-negative")) {
            *count = -1;
            return EGL_TRUE;
        }
        if (max && scenario == "format-list-overflow") {
            *count = max + 1; // Never write outside the supplied array.
            return EGL_TRUE;
        }
        if (max && scenario == "format-list-zero") {
            *count = 0;
            return EGL_TRUE;
        }
    }
    QList<uint32_t> values = {DRM_FORMAT_XRGB8888, DRM_FORMAT_ARGB8888, DRM_FORMAT_XBGR8888, DRM_FORMAT_NV12};
    if (currentPhase) {
        if (scenario == "no-formats") {
            values.clear();
        } else if (scenario == "empty-intersection") {
            values = {DRM_FORMAT_ABGR8888};
        } else if (scenario == "only-external") {
            values = {DRM_FORMAT_NV12};
        } else {
            // New AB24 must not expand the original cache; XB24 disappears.
            values = {DRM_FORMAT_XRGB8888, DRM_FORMAT_ARGB8888, DRM_FORMAT_NV12, DRM_FORMAT_ABGR8888};
        }
    }
    *count = values.size();
    if (max) {
        assert(out && max >= values.size());
        std::copy(values.cbegin(), values.cend(), out);
    }
    return EGL_TRUE;
}

static EGLBoolean EGLAPIENTRY queryModifiers(::EGLDisplay display, EGLint format, EGLint max,
                                             EGLuint64KHR *out, EGLBoolean *external, EGLint *count)
{
    assert(display == expectedDisplay && count && max >= 0);
    if (currentPhase) {
        ++modifierQueries;
        if (scenario == (max ? "modifier-list-failure" : "modifier-count-failure") ||
            (format == DRM_FORMAT_ARGB8888 && scenario == (max ? "mixed-modifier-list-failure" : "mixed-modifier-count-failure"))) {
            return EGL_FALSE;
        }
        if (!max && scenario == "modifier-count-overflow") {
            *count = 4097;
            return EGL_TRUE;
        }
        if (scenario == (max ? "modifier-list-negative" : "modifier-count-negative")) {
            *count = -1;
            return EGL_TRUE;
        }
        if (max && scenario == "modifier-list-overflow") {
            *count = max + 1;
            return EGL_TRUE;
        }
        if (max && scenario == "modifier-list-zero") {
            *count = 0;
            return EGL_TRUE;
        }
        if (scenario == "implicit-modifiers") {
            *count = 0;
            return EGL_TRUE;
        }
    }
    QList<EGLuint64KHR> values = {DRM_FORMAT_MOD_LINEAR};
    if (format == DRM_FORMAT_XRGB8888) {
        values.append(currentPhase ? 2 : 1);
    }
    *count = values.size();
    if (max) {
        assert(out && external && max >= values.size());
        for (qsizetype i = 0; i < values.size(); ++i) {
            out[i] = values[i];
            // A formerly external-only format must not become renderable
            // merely because a later query reports broader support.
            external[i] = (format == DRM_FORMAT_NV12 && (!currentPhase || scenario == "only-external"))
                || (format == DRM_FORMAT_ARGB8888 && currentPhase && scenario == "newly-external");
        }
    }
    return EGL_TRUE;
}

static __eglMustCastToProperFunctionPointerType EGLAPIENTRY getProc(const char *name)
{
    if (!std::strcmp(name, "eglQueryDmaBufFormatsEXT")) {
        return reinterpret_cast<__eglMustCastToProperFunctionPointerType>(queryFormats);
    }
    if (!std::strcmp(name, "eglQueryDmaBufModifiersEXT")) {
        return scenario == "no-modifier-callback" ? nullptr : reinterpret_cast<__eglMustCastToProperFunctionPointerType>(queryModifiers);
    }
    assert(!std::strcmp(name, "eglCreateImageKHR") || !std::strcmp(name, "eglDestroyImageKHR"));
    return nullptr;
}

int main(int argc, char **argv)
{
    assert(argc == 2);
    scenario = argv[1];
    epoxy_eglQueryString = queryString;
    epoxy_eglGetProcAddress = getProc;
    epoxy_eglGetCurrentDisplay = currentDisplay;
    epoxy_eglGetCurrentContext = currentContext;
    epoxy_eglGetError = getError;
    epoxy_eglTerminate = terminate;
    epoxy_glGetString = renderer;
    {
        EglDisplay display(expectedDisplay,
            {QByteArrayLiteral("EGL_EXT_image_dma_buf_import"), QByteArrayLiteral("EGL_EXT_image_dma_buf_import_modifiers")},
            scenario == "no-drm-device" ? nullptr : reinterpret_cast<DrmDevice *>(uintptr_t(0x2000)));
        const auto originalAll = display.allSupportedDrmFormats();
        const auto originalRender = display.nonExternalOnlySupportedDrmFormats();
        assert(originalAll.containsFormat(DRM_FORMAT_XBGR8888, DRM_FORMAT_MOD_INVALID));
        assert(originalRender.containsFormat(DRM_FORMAT_XBGR8888, DRM_FORMAT_MOD_LINEAR));
        if (scenario != "no-modifier-callback") {
            assert(!originalRender.containsFormat(DRM_FORMAT_NV12, DRM_FORMAT_MOD_LINEAR));
        }
        currentPhase = true;
        const bool result = display.restrictMtgpuFormatsToCurrentContext();
        const bool bypass = scenario == "other-driver" || scenario == "no-drm-device" || scenario == "other-model";
        const bool mixed = scenario == "mixed-modifier-count-failure" || scenario == "mixed-modifier-list-failure";
        const bool success = scenario == "intersection" || scenario == "implicit-modifiers" || scenario == "newly-external" || mixed;
        assert(result == (success || bypass));
        if (bypass) {
            assert(display.allSupportedDrmFormats() == originalAll);
            assert(display.nonExternalOnlySupportedDrmFormats() == originalRender);
            assert(formatQueries == 0 && modifierQueries == 0);
            if (scenario != "other-model") {
                assert(currentQueries == 0);
            }
        } else if (success) {
            const auto &all = display.allSupportedDrmFormats();
            const auto &render = display.nonExternalOnlySupportedDrmFormats();
            assert(!all.contains(DRM_FORMAT_XBGR8888));
            assert(!render.contains(DRM_FORMAT_XBGR8888));
            assert(!all.contains(DRM_FORMAT_ABGR8888));
            assert(!render.contains(DRM_FORMAT_ABGR8888));
            assert(all.containsFormat(DRM_FORMAT_XRGB8888, DRM_FORMAT_MOD_LINEAR));
            assert(render.containsFormat(DRM_FORMAT_XRGB8888, DRM_FORMAT_MOD_LINEAR));
            assert(render.containsFormat(DRM_FORMAT_XRGB8888, DRM_FORMAT_MOD_INVALID));
            assert(render.containsFormat(DRM_FORMAT_ARGB8888, DRM_FORMAT_MOD_LINEAR) == (!mixed && scenario != "newly-external"));
            assert(all.contains(DRM_FORMAT_ARGB8888) == !mixed);
            if (scenario == "newly-external") {
                assert(!render.contains(DRM_FORMAT_ARGB8888)); // Empty modifier keys are removed.
            }
            assert(!all.containsFormat(DRM_FORMAT_XRGB8888, 1));
            assert(!all.containsFormat(DRM_FORMAT_XRGB8888, 2));
            assert(all.containsFormat(DRM_FORMAT_NV12, DRM_FORMAT_MOD_LINEAR));
            assert(!render.containsFormat(DRM_FORMAT_NV12, DRM_FORMAT_MOD_LINEAR));
            assert(!render.containsFormat(DRM_FORMAT_NV12, DRM_FORMAT_MOD_INVALID));
            assert(formatQueries == 2 && modifierQueries > 0);
        } else {
            assert(display.allSupportedDrmFormats().empty());
            assert(display.nonExternalOnlySupportedDrmFormats().empty());
        }
        std::cout << "case=" << scenario << " success=" << result
                  << " format_queries=" << formatQueries << " modifier_queries=" << modifierQueries << '\n';
    }
    assert(terminated);
}
