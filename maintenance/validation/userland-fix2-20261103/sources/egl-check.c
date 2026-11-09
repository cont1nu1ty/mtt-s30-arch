/* SPDX-License-Identifier: MIT
 * GLES3 draw/readback through GBM, or an xdg-shell window with presentation
 * feedback. Software modes are explicit harness controls, never S30 success.
 */
#define _GNU_SOURCE
#define _POSIX_C_SOURCE 200809L
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <gbm.h>
#include <xf86drm.h>
#include <wayland-client.h>
#include <wayland-egl.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <link.h>
#include "xdg-shell-client-protocol.h"
#include "presentation-time-client-protocol.h"

#define W 256
#define H 192
static int graphics_library(struct dl_phdr_info *info, size_t size, void *data);
#define REQUIRE(c,m) do { if (!(c)) { \
    EGLint saved_egl_error=eglGetError(); \
    GLenum saved_gl_error=glGetError(); \
    fprintf(stderr,"%s (EGL=%x GL=%x)\n",m,saved_egl_error,saved_gl_error); \
    dl_iterate_phdr(graphics_library,NULL);exit(2); \
} } while(0)
static struct wl_display *display;
static struct wl_compositor *compositor;
static struct xdg_wm_base *shell;
static struct wp_presentation *presentation;
static int configured, presented, discarded;
static unsigned hardware_presentations, flags_all=~0u;
static uint64_t last_time;

static int graphics_library(struct dl_phdr_info *info, size_t size, void *data)
{
    (void)size; (void)data;
    if (strstr(info->dlpi_name,"libEGL_") || strstr(info->dlpi_name,"mtgpu_dri.so") ||
        strstr(info->dlpi_name,"musa_dri.so")) printf("Graphics library: %s\n",info->dlpi_name);
    return 0;
}

static void ping(void *d, struct xdg_wm_base *s, uint32_t serial)
{ (void)d;xdg_wm_base_pong(s,serial); }
static const struct xdg_wm_base_listener shell_listener={.ping=ping};
static void registry_global(void *d, struct wl_registry *r, uint32_t id, const char *name, uint32_t version)
{
    (void)d;(void)version;
    if (!strcmp(name,"wl_compositor")) compositor=wl_registry_bind(r,id,&wl_compositor_interface,1);
    else if (!strcmp(name,"xdg_wm_base")) {
        shell=wl_registry_bind(r,id,&xdg_wm_base_interface,1);
        xdg_wm_base_add_listener(shell,&shell_listener,NULL);
    } else if (!strcmp(name,"wp_presentation")) presentation=wl_registry_bind(r,id,&wp_presentation_interface,1);
}
static void registry_remove(void *d,struct wl_registry *r,uint32_t id)
{ (void)d;(void)r;(void)id; }
static const struct wl_registry_listener registry_listener={registry_global,registry_remove};
static void configure(void *d,struct xdg_surface *s,uint32_t serial)
{ (void)d;xdg_surface_ack_configure(s,serial);configured=1; }
static const struct xdg_surface_listener surface_listener={configure};
static void top_configure(void *d,struct xdg_toplevel *s,int32_t w,int32_t h,struct wl_array *states)
{ (void)d;(void)s;(void)w;(void)h;(void)states; }
static void top_close(void *d,struct xdg_toplevel *s)
{ (void)d;(void)s;fprintf(stderr,"Test window closed prematurely\n");exit(2); }
static const struct xdg_toplevel_listener top_listener={.configure=top_configure,.close=top_close};
static void clock_id(void *d,struct wp_presentation *p,uint32_t id)
{ (void)d;(void)p;printf("Presentation clock: %u\n",id); }
static const struct wp_presentation_listener presentation_listener={clock_id};
static void sync_output(void *d,struct wp_presentation_feedback *f,struct wl_output *o)
{ (void)d;(void)f;(void)o; }
static void frame_presented(void *d,struct wp_presentation_feedback *f,uint32_t hi,uint32_t lo,
        uint32_t ns,uint32_t refresh,uint32_t seq_hi,uint32_t seq_lo,uint32_t flags)
{
    (void)d;(void)refresh;(void)seq_hi;(void)seq_lo;
    uint64_t now=(((uint64_t)hi<<32)|lo)*1000000000ull+ns;
    REQUIRE(ns<1000000000 && now>last_time,"Presentation timestamps did not advance");
    last_time=now;flags_all&=flags;
    if ((flags&6)==6) hardware_presentations++;
    presented++;wp_presentation_feedback_destroy(f);
}
static void frame_discarded(void *d,struct wp_presentation_feedback *f)
{ (void)d;discarded++;wp_presentation_feedback_destroy(f); }
static const struct wp_presentation_feedback_listener feedback_listener={sync_output,frame_presented,frame_discarded};

static GLuint shader(GLenum kind,const char *source)
{
    GLuint s=glCreateShader(kind);glShaderSource(s,1,&source,NULL);glCompileShader(s);
    GLint ok;glGetShaderiv(s,GL_COMPILE_STATUS,&ok);
    if (!ok) {char log[2048];glGetShaderInfoLog(s,sizeof log,NULL,log);fprintf(stderr,"%s\n",log);exit(2);}
    return s;
}
static void json_string(const char *s)
{
    putchar('"');for (;*s;s++) {unsigned char c=(unsigned char)*s;
        if(c=='"'||c=='\\') putchar('\\');
        if(c<32) printf("\\u%04x",c);else putchar(c);
    }putchar('"');
}

int main(int argc,char **argv)
{
    setvbuf(stdout,NULL,_IOLBF,0);
    REQUIRE(argc==4,"Usage: egl-check gbm|wayland|software-surfaceless|software-wayland DEVICE_OR_DASH OUTPUT.rgba");
    int window=!strcmp(argv[1],"wayland")||!strcmp(argv[1],"software-wayland");
    int software=!strcmp(argv[1],"software-surfaceless")||!strcmp(argv[1],"software-wayland");
    REQUIRE(window||software||!strcmp(argv[1],"gbm"),"Unknown mode");
    unsigned frames=window?60:8;
    const char *mode=software?(window?"wayland-software":"surfaceless-software"):(window?"wayland-s30":"gbm-s30");
    struct gbm_device *gbm=NULL;int fd=-1;
    struct wl_surface *surface=NULL;struct xdg_surface *xdg=NULL;struct xdg_toplevel *top=NULL;
    struct wl_registry *registry=NULL;struct wl_egl_window *native_window=NULL;
    EGLDisplay ed=EGL_NO_DISPLAY;
    PFNEGLGETPLATFORMDISPLAYEXTPROC get_display=(void *)eglGetProcAddress("eglGetPlatformDisplayEXT");
    REQUIRE(get_display,"EGL platform display entry missing");
    if (window) {
        display=wl_display_connect(NULL);REQUIRE(display,"Cannot connect private Wayland display");
        registry=wl_display_get_registry(display);wl_registry_add_listener(registry,&registry_listener,NULL);
        REQUIRE(wl_display_roundtrip(display)>=0,"Wayland registry failed");
        REQUIRE(compositor&&shell&&presentation,"Required Wayland globals missing");
        wp_presentation_add_listener(presentation,&presentation_listener,NULL);
        surface=wl_compositor_create_surface(compositor);xdg=xdg_wm_base_get_xdg_surface(shell,surface);
        xdg_surface_add_listener(xdg,&surface_listener,NULL);top=xdg_surface_get_toplevel(xdg);
        xdg_toplevel_add_listener(top,&top_listener,NULL);
        xdg_toplevel_set_title(top,"MTT S30 - isolated GLES correctness test");
        xdg_toplevel_set_app_id(top,"org.mtt.s30.validation");
        xdg_toplevel_set_min_size(top,W,H);xdg_toplevel_set_max_size(top,W,H);
        wl_surface_commit(surface);
        while(!configured) REQUIRE(wl_display_dispatch(display)>=0,"Window configure failed");
        native_window=wl_egl_window_create(surface,W,H);REQUIRE(native_window,"Cannot create native window");
        ed=get_display(EGL_PLATFORM_WAYLAND_EXT,display,NULL);
    } else if (software) {
        ed=get_display(EGL_PLATFORM_SURFACELESS_MESA,EGL_DEFAULT_DISPLAY,NULL);
    } else {
        fd=open(argv[2],O_RDWR|O_CLOEXEC);REQUIRE(fd>=0,"Cannot open render node");
        drmVersionPtr version=drmGetVersion(fd);
        REQUIRE(version&&!strcmp(version->name,"mtgpu"),"Render node is not mtgpu");drmFreeVersion(version);
        gbm=gbm_create_device(fd);REQUIRE(gbm,"GBM device creation failed");
        printf("GBM backend: %s\n",gbm_device_get_backend_name(gbm));
        ed=get_display(EGL_PLATFORM_GBM_KHR,gbm,NULL);
    }
    REQUIRE(ed!=EGL_NO_DISPLAY,"EGL platform display creation failed");
    REQUIRE(eglInitialize(ed,NULL,NULL),"EGL initialization failed");
    printf("EGL vendor: %s\nEGL version: %s\n",eglQueryString(ed,EGL_VENDOR),eglQueryString(ed,EGL_VERSION));
    char egl_vendor_copy[512];snprintf(egl_vendor_copy,sizeof egl_vendor_copy,"%s",eglQueryString(ed,EGL_VENDOR));
    dl_iterate_phdr(graphics_library,NULL);
    REQUIRE(eglBindAPI(EGL_OPENGL_ES_API),"Cannot select GLES");
    EGLint attrs[]={EGL_RENDERABLE_TYPE,EGL_OPENGL_ES3_BIT,EGL_SURFACE_TYPE,window?EGL_WINDOW_BIT:0,
                   EGL_RED_SIZE,8,EGL_GREEN_SIZE,8,EGL_BLUE_SIZE,8,EGL_ALPHA_SIZE,8,EGL_NONE};
    EGLConfig config;EGLint count;
    REQUIRE(eglChooseConfig(ed,attrs,&config,1,&count)&&count==1,"No GLES3 RGBA8 config");
    EGLint ca[]={EGL_CONTEXT_CLIENT_VERSION,3,EGL_NONE};
    EGLContext context=eglCreateContext(ed,config,EGL_NO_CONTEXT,ca);REQUIRE(context!=EGL_NO_CONTEXT,"GLES3 context creation failed");
    EGLSurface es=window?eglCreateWindowSurface(ed,config,(EGLNativeWindowType)native_window,NULL):EGL_NO_SURFACE;
    REQUIRE(!window||es!=EGL_NO_SURFACE,"Wayland EGL surface creation failed");
    REQUIRE(eglMakeCurrent(ed,es,es,context),"EGL make-current failed");
    const char *renderer=(const char *)glGetString(GL_RENDERER),*vendor=(const char *)glGetString(GL_VENDOR);
    REQUIRE(renderer&&vendor,"Missing GLES identity");
    char renderer_copy[512],vendor_copy[512];snprintf(renderer_copy,sizeof renderer_copy,"%s",renderer);snprintf(vendor_copy,sizeof vendor_copy,"%s",vendor);
    printf("GL vendor: %s\nGL renderer: %s\nGL version: %s\n",vendor,renderer,glGetString(GL_VERSION));fflush(stdout);
    int cpu=strstr(renderer,"llvmpipe")||strstr(renderer,"softpipe");
    REQUIRE(software?cpu:(!cpu&&strstr(renderer,"S30")),"Unexpected renderer; fallback forbidden");
    GLuint texture=0,fbo=0;
    if(!window) {
        glGenTextures(1,&texture);glBindTexture(GL_TEXTURE_2D,texture);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,W,H,0,GL_RGBA,GL_UNSIGNED_BYTE,NULL);
        glGenFramebuffers(1,&fbo);glBindFramebuffer(GL_FRAMEBUFFER,fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,texture,0);
        REQUIRE(glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE,"Incomplete RGBA framebuffer");
    } else REQUIRE(eglSwapInterval(ed,1),"Cannot select swap interval");
    const char *vs="#version 300 es\nconst vec2 p[3]=vec2[3](vec2(-1,-1),vec2(3,-1),vec2(-1,3));void main(){gl_Position=vec4(p[gl_VertexID],0,1);}";
    const char *fs="#version 300 es\nprecision highp float;precision highp int;uniform int frame;out vec4 color;void main(){int t=(int(gl_FragCoord.x)/16+3*(int(gl_FragCoord.y)/16)+frame)%4;color=t==0?vec4(1,0,0,1):t==1?vec4(0,1,0,1):t==2?vec4(0,0,1,1):vec4(1);}";
    GLuint vert=shader(GL_VERTEX_SHADER,vs),frag=shader(GL_FRAGMENT_SHADER,fs),program=glCreateProgram();
    glAttachShader(program,vert);glAttachShader(program,frag);glLinkProgram(program);
    GLint ok;glGetProgramiv(program,GL_LINK_STATUS,&ok);REQUIRE(ok,"GLES program link failed");glUseProgram(program);
    GLint uniform=glGetUniformLocation(program,"frame");REQUIRE(uniform>=0,"Frame uniform missing");
    glViewport(0,0,W,H);glDisable(GL_DITHER);glDisable(GL_BLEND);
    unsigned char *pixels=malloc(W*H*4);REQUIRE(pixels,"Cannot allocate readback");
    static const unsigned char colors[4][4]={{255,0,0,255},{0,255,0,255},{0,0,255,255},{255,255,255,255}};
    for(unsigned frame=0;frame<frames;frame++) {
        glUniform1i(uniform,(GLint)frame);glDrawArrays(GL_TRIANGLES,0,3);
        glReadPixels(0,0,W,H,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
        REQUIRE(glGetError()==GL_NO_ERROR,"GLES draw or readback failed");
        for(unsigned y=0;y<H;y++) for(unsigned x=0;x<W;x++) {
            const unsigned char *expected=colors[(x/16+3*(y/16)+frame)%4];
            if(memcmp(pixels+(y*W+x)*4,expected,4)) {
                fprintf(stderr,"Pixel mismatch frame=%u x=%u y=%u\n",frame,x,y);return 3;
            }
        }
        if(window) {
            struct wp_presentation_feedback *feedback=wp_presentation_feedback(presentation,surface);
            wp_presentation_feedback_add_listener(feedback,&feedback_listener,NULL);
            REQUIRE(eglSwapBuffers(ed,es),"Window buffer swap failed");
            while(presented<((int)frame+1)&&!discarded) REQUIRE(wl_display_dispatch(display)>=0,"Presentation dispatch failed");
            REQUIRE(!discarded,"Compositor discarded a test frame");
        }
    }
    REQUIRE(!window||software||hardware_presentations==frames,"Missing hardware presentation feedback");
    FILE *out=fopen(argv[3],"wb");REQUIRE(out,"Cannot save output");
    REQUIRE(fwrite(pixels,1,W*H*4,out)==W*H*4&&fclose(out)==0,"Cannot write output");free(pixels);
    glDeleteProgram(program);glDeleteShader(vert);glDeleteShader(frag);
    if(fbo)glDeleteFramebuffers(1,&fbo);
    if(texture)glDeleteTextures(1,&texture);
    REQUIRE(eglMakeCurrent(ed,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT),"Cannot release EGL context");
    if(window)REQUIRE(eglDestroySurface(ed,es),"Cannot destroy EGL surface");
    REQUIRE(eglDestroyContext(ed,context)&&eglTerminate(ed),"EGL cleanup failed");
    if(window) {
        wl_egl_window_destroy(native_window);xdg_toplevel_destroy(top);xdg_surface_destroy(xdg);wl_surface_destroy(surface);
        wp_presentation_destroy(presentation);xdg_wm_base_destroy(shell);wl_compositor_destroy(compositor);wl_registry_destroy(registry);
        REQUIRE(wl_display_roundtrip(display)>=0,"Window destruction roundtrip failed");wl_display_disconnect(display);
    }
    if(gbm)gbm_device_destroy(gbm);
    if(fd>=0)close(fd);
    printf("{\"passed\":true,\"mode\":\"%s\",\"frames\":%u,\"pixels_checked\":%u,\"mismatches\":0,\"presented\":%d,\"discarded\":%d,\"hardware_presentations\":%u,\"presentation_flags_all\":%u,\"renderer\":",mode,frames,frames*W*H,presented,discarded,hardware_presentations,window?flags_all:0);
    json_string(renderer_copy);printf(",\"vendor\":");json_string(vendor_copy);
    printf(",\"egl_vendor\":");json_string(egl_vendor_copy);puts("}");return 0;
}
