// SPDX-License-Identifier: MIT
// A direct desktop-OpenGL/GLX workload on the explicitly selected XWayland display.
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <GL/glxext.h>
#include <xcb/xcb.h>
#include <xcb/dri3.h>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <link.h>
#include <string>
#include <thread>
#include <vector>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <unistd.h>

constexpr int Width = 256, Height = 192, Frames = 12;
static int xErrors = 0;
static int xError(Display *display, XErrorEvent *event)
{
    char text[256];
    XGetErrorText(display, event->error_code, text, sizeof text);
    std::fprintf(stderr, "X11 error: %s request=%u minor=%u\n", text, event->request_code, event->minor_code);
    ++xErrors;
    return 0;
}

static void jsonString(const std::string &text)
{
    std::putchar('"');
    for (const unsigned char c : text) {
        if (c == '\\' || c == '"') std::putchar('\\');
        if (c < 32) std::printf("\\u%04x", c); else std::putchar(c);
    }
    std::putchar('"');
}

static int graphicsLibrary(dl_phdr_info *info, size_t, void *)
{
    const std::string name(info->dlpi_name);
    if (name.find("libGL") != std::string::npos || name.find("libEGL") != std::string::npos ||
        name.find("_dri.so") != std::string::npos)
        std::printf("Graphics library: %s\n", info->dlpi_name);
    return 0;
}

int main(int argc, char **argv)
{
    std::setvbuf(stdout, nullptr, _IOLBF, 0);
    if (argc != 3 || (std::strcmp(argv[1], "s30") && std::strcmp(argv[1], "software"))) {
        std::fprintf(stderr, "Usage: x11-check s30|software OUTPUT.rgba\n");
        return 2;
    }
    const bool software = !std::strcmp(argv[1], "software");
    Display *display = nullptr;
    GLXContext context = nullptr;
    Window window = 0;
    Colormap colormap = 0;
    std::string error, renderer, vendor, version, glxVendor, serverVendor, dri3Node;
    int glMajor = 0, glMinor = 0, checked = 0, swaps = 0;
    bool direct = false, xwayland = false, dri3 = false;
    unsigned dri3Major = 0, dri3Minor = 0;
    std::vector<unsigned char> pixels(Width * Height * 4);
    const unsigned char colors[4][4] = {{255,0,0,255}, {0,255,0,255}, {0,0,255,255}, {255,255,255,255}};
    XSetErrorHandler(xError);
    auto require = [](bool value, const char *message) { if (!value) throw std::string(message); };
    try {
        require(std::getenv("DISPLAY") && std::getenv("XAUTHORITY"), "Explicit DISPLAY and XAUTHORITY are required");
        display = XOpenDisplay(nullptr);
        require(display, "Cannot open selected X11 display");
        int opcode, event, eventError;
        xwayland = XQueryExtension(display, "XWAYLAND", &opcode, &event, &eventError);
        require(xwayland, "Selected X server does not advertise XWAYLAND");
        dri3 = XQueryExtension(display, "DRI3", &opcode, &event, &eventError);
        serverVendor = ServerVendor(display);
        const int screen = DefaultScreen(display);
        if (dri3) {
            int xcbScreen = 0;
            xcb_connection_t *xcb = xcb_connect(nullptr, &xcbScreen);
            require(xcb && !xcb_connection_has_error(xcb), "Cannot open independent XCB connection");
            auto screens = xcb_setup_roots_iterator(xcb_get_setup(xcb));
            for (int i = 0; i < xcbScreen && screens.rem; ++i) xcb_screen_next(&screens);
            if (!screens.rem) { xcb_disconnect(xcb); throw std::string("Missing XCB root screen"); }
            xcb_generic_error_t *xcbError = nullptr;
            auto cookie = xcb_dri3_open(xcb, screens.data->root, 0);
            xcb_dri3_open_reply_t *reply = xcb_dri3_open_reply(xcb, cookie, &xcbError);
            if (reply && !xcbError && reply->nfd == 1) {
                const int fd = xcb_dri3_open_reply_fds(xcb, reply)[0];
                char link[512];
                const std::string path = "/proc/self/fd/" + std::to_string(fd);
                const ssize_t length = readlink(path.c_str(), link, sizeof link - 1);
                struct stat info{};
                if (length > 0 && !fstat(fd, &info) && S_ISCHR(info.st_mode)) {
                    link[length] = '\0'; dri3Node = link;
                    dri3Major = major(info.st_rdev); dri3Minor = minor(info.st_rdev);
                }
                close(fd);
            } else if (reply) {
                int *fds = xcb_dri3_open_reply_fds(xcb, reply);
                for (unsigned i = 0; i < reply->nfd; ++i) close(fds[i]);
            }
            if (xcbError) std::fprintf(stderr, "DRI3 open error=%u\n", xcbError->error_code);
            std::free(xcbError); std::free(reply); xcb_disconnect(xcb);
        }
        const char *extensions = glXQueryExtensionsString(display, screen);
        require(extensions && std::strstr(extensions, "GLX_ARB_create_context"), "Desktop GLX context creation unavailable");
        const int attributes[] = {GLX_X_RENDERABLE, True, GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
            GLX_RENDER_TYPE, GLX_RGBA_BIT, GLX_X_VISUAL_TYPE, GLX_TRUE_COLOR,
            GLX_RED_SIZE, 8, GLX_GREEN_SIZE, 8, GLX_BLUE_SIZE, 8, GLX_ALPHA_SIZE, 8,
            GLX_DOUBLEBUFFER, True, None};
        int count = 0;
        GLXFBConfig *configs = glXChooseFBConfig(display, screen, attributes, &count);
        require(configs && count, "No RGBA8 double-buffered GLX configuration");
        GLXFBConfig config = configs[0];
        XFree(configs);
        XVisualInfo *visual = glXGetVisualFromFBConfig(display, config);
        require(visual, "No X11 visual for GLX configuration");
        colormap = XCreateColormap(display, RootWindow(display, screen), visual->visual, AllocNone);
        XSetWindowAttributes windowAttributes{};
        windowAttributes.colormap = colormap;
        windowAttributes.event_mask = StructureNotifyMask;
        window = XCreateWindow(display, RootWindow(display, screen), 0, 0, Width, Height, 0,
            visual->depth, InputOutput, visual->visual, CWColormap | CWEventMask, &windowAttributes);
        XFree(visual);
        require(window, "Cannot create GLX X11 window");
        XStoreName(display, window, "MTT S30 - XWayland GLX validation");
        XSizeHints hints{};
        hints.flags = PMinSize | PMaxSize;
        hints.min_width = hints.max_width = Width;
        hints.min_height = hints.max_height = Height;
        XSetWMNormalHints(display, window, &hints);
        XMapWindow(display, window);
        XFlush(display);
        const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(5);
        bool mapped = false;
        while (!mapped && std::chrono::steady_clock::now() < deadline) {
            while (XPending(display)) {
                XEvent ev;
                XNextEvent(display, &ev);
                if (ev.type == MapNotify && ev.xmap.window == window) mapped = true;
            }
            if (!mapped) std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        require(mapped, "XWayland window did not map");
        auto createContext = reinterpret_cast<PFNGLXCREATECONTEXTATTRIBSARBPROC>(
            glXGetProcAddressARB(reinterpret_cast<const GLubyte *>("glXCreateContextAttribsARB")));
        require(createContext, "Missing GLX_ARB_create_context entrypoint");
        const int contextAttributes[] = {GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
            GLX_CONTEXT_MINOR_VERSION_ARB, 3, GLX_CONTEXT_PROFILE_MASK_ARB,
            GLX_CONTEXT_CORE_PROFILE_BIT_ARB, None};
        context = createContext(display, config, nullptr, True, contextAttributes);
        XSync(display, False);
        require(context && !xErrors, "Cannot create desktop OpenGL 3.3 core GLX context");
        require(glXMakeCurrent(display, window, context), "Cannot make GLX context current");
        direct = glXIsDirect(display, context);
        require(direct, "Indirect GLX rendering is not accepted");
        auto glText = [](GLenum name) {
            const auto *s = glGetString(name);
            return s ? std::string(reinterpret_cast<const char *>(s)) : std::string();
        };
        renderer = glText(GL_RENDERER); vendor = glText(GL_VENDOR); version = glText(GL_VERSION);
        const char *gv = glXGetClientString(display, GLX_VENDOR);
        glxVendor = gv ? gv : "";
        glGetIntegerv(GL_MAJOR_VERSION, &glMajor); glGetIntegerv(GL_MINOR_VERSION, &glMinor);
        std::printf("GL renderer: %s\nGL vendor: %s\nGL version: %s\nGLX vendor: %s\n",
                    renderer.c_str(), vendor.c_str(), version.c_str(), glxVendor.c_str());
        dl_iterate_phdr(graphicsLibrary, nullptr);
        const bool cpu = renderer.find("llvmpipe") != std::string::npos || renderer.find("softpipe") != std::string::npos;
        require(!renderer.empty() && (software ? cpu : !cpu && renderer.find("S30") != std::string::npos),
                "Unexpected GLX renderer; software fallback is not hardware acceptance");
        require(software || dri3, "Hardware XWayland must expose DRI3");
        require(software || dri3Node.rfind("/dev/dri/renderD", 0) == 0,
                "DRI3 did not return a render-node file descriptor");
        require(version.find("OpenGL ES") == std::string::npos && (glMajor > 3 || (glMajor == 3 && glMinor >= 3)),
                "Expected desktop OpenGL >= 3.3, not GLES");
        glViewport(0, 0, Width, Height);
        glDisable(GL_DITHER);
        glDisable(GL_FRAMEBUFFER_SRGB);
        glEnable(GL_SCISSOR_TEST);
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        for (int frame = 0; frame < Frames; ++frame) {
            XWindowAttributes actual;
            require(XGetWindowAttributes(display, window, &actual) && actual.map_state == IsViewable &&
                    actual.width == Width && actual.height == Height, "XWayland window geometry/visibility changed");
            for (int y = 0; y < Height; y += 16)
                for (int x = 0; x < Width; x += 16) {
                    const auto *color = colors[(x / 16 + 3 * (y / 16) + frame) % 4];
                    glScissor(x, y, 16, 16);
                    glClearColor(color[0] / 255.f, color[1] / 255.f, color[2] / 255.f, 1.f);
                    glClear(GL_COLOR_BUFFER_BIT);
                }
            glReadBuffer(GL_BACK);
            glReadPixels(0, 0, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, pixels.data());
            require(glGetError() == GL_NO_ERROR, "GLX workload reported a GL error");
            for (int y = 0; y < Height; ++y)
                for (int x = 0; x < Width; ++x)
                    require(!std::memcmp(&pixels[(y * Width + x) * 4], colors[(x / 16 + 3 * (y / 16) + frame) % 4], 4),
                            "GLX pixel mismatch");
            ++checked;
            glXSwapBuffers(display, window); ++swaps;
            XSync(display, False);
            require(!xErrors, "X11 error during GLX swap");
            std::this_thread::sleep_for(std::chrono::milliseconds(30));
        }
        FILE *file = std::fopen(argv[2], "wb");
        require(file, "Cannot open GLX output file");
        const bool written = std::fwrite(pixels.data(), 1, pixels.size(), file) == pixels.size();
        const bool closed = !std::fclose(file);
        require(written && closed, "Cannot save GLX pixels");
    } catch (const std::string &message) { error = message; }
    if (display) {
        if (context) {
            if (!glXMakeCurrent(display, None, nullptr) && error.empty()) error = "Cannot release GLX context";
            glXDestroyContext(display, context);
        }
        if (window) XDestroyWindow(display, window);
        if (colormap) XFreeColormap(display, colormap);
        XSync(display, False);
        XCloseDisplay(display);
    }
    if (!error.empty() || xErrors || checked != Frames || swaps != Frames) {
        std::fprintf(stderr, "%s checked=%d swaps=%d x_errors=%d\n", error.c_str(), checked, swaps, xErrors);
        return 2;
    }
    std::printf("{\"passed\":true,\"mode\":\"xwayland-glx-%s\",\"frames\":%d,\"pixels_checked\":%d,"
                "\"mismatches\":0,\"swapped\":%d,\"direct\":true,\"xwayland_extension\":true,"
                "\"desktop_opengl\":true,\"gl_major\":%d,\"gl_minor\":%d,\"window_destroyed\":true,"
                "\"context_destroyed\":true,\"display_closed\":true,\"renderer\":",
                software ? "software" : "s30", Frames, Frames * Width * Height, swaps, glMajor, glMinor);
    jsonString(renderer); std::printf(",\"vendor\":"); jsonString(vendor);
    std::printf(",\"gl_version\":"); jsonString(version);
    std::printf(",\"glx_vendor\":"); jsonString(glxVendor);
    std::printf(",\"xserver_vendor\":"); jsonString(serverVendor);
    std::printf(",\"dri3_extension\":%s,\"dri3_node\":", dri3 ? "true" : "false"); jsonString(dri3Node);
    std::printf(",\"dri3_device_major\":%u,\"dri3_device_minor\":%u", dri3Major, dri3Minor);
    std::puts("}");
    return 0;
}
