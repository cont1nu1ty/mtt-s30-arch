# S30 Wayland GLES dispatch review

On the 20261105-144027 v8 run, the client progressed past context creation, window surface creation and eglMakeCurrent. Its first GL identity check exited with “Missing GLES identity (EGL=3000 GL=0)”. That check requires both GL_RENDERER and GL_VENDOR. The log records the combined failure and does not identify which individual pointer was null.

The following local ELF and source findings explain how the thread dispatch namespaces diverge.

- The pinned official libEGL_mtgpu.so.0 links libglapi_musa.so.0. Its driver procedure resolver is a tail jump at 0x342e0 to musa_glapi_get_proc_address@plt, referenced by a relative relocation at 0x24d318. At 0x342bc an internal resolver also requests glFlush from that provider.
- The secondary musa_dri.so links libglapi_musa.so.0 and imports musa_glapi_set_dispatch. Its dispatch selection paths at 0xa6d2, 0xa704 and 0xa71e target that symbol. In libglapi_musa.so.0 the setter at 0x300b0 reaches the TLS write at 0x3097c, via the TPOFF64 relocation for musa_glapi_tls_Dispatch at 0x254fb8. The primary mtgpu_dri.so also contains strings for dynamically loading libglapi_musa.so.0 and resolving musa_glapi_set_dispatch. The GL API library has SHA256 c130e2756e374e5ef6a843a0e9d93bfba1674412249a4a426858e2f381acd569.
- The independently built v8 libEGL_mesa.so.0 instead imports _glapi_get_proc_address from ordinary libglapi.so.0. The vendor ABI callback in Mesa eglglvnd.c forwards public GL names to eglGetProcAddress. In eglapi.c:2818 it calls _glapi_get_proc_address. egl_dri2.c:142 also uses that namespace for the internal glFlush pointer.
- These libraries expose separate thread-local dispatch tables. The on-device TLS itself was not read. The v8 hardware log and the following CPU counterexample distinguish this dispatch failure from the earlier window-surface creation crash and compositor format failure.

The reusable tool directly starts the EGL vendor ABI with __egl_Main and calls imports.getProcAddress before any test dispatch table is bound. It executes the private EGL's own linked dri2_gl_flush_get for the internal path and checks all 29 public GL names used by egl-check against the chosen provider. It binds CPU sentinel functions to the real providers' slot offsets. glGetString, glCreateShader, glUniform1i and the internal glFlush exercise return values, arguments, per-thread bindings, switching and release.

The v8 negative control binds only the MUSA table. Both GL identity queries via the v8 vendor ABI return NULL, while querying the bound MUSA table reaches the sentinel. The v9 vendor case reaches it using the cached EGL entries. Additional cases exercise the ordinary Mesa namespace with the feature disabled and rejection of a missing library, missing resolver, and a relative path. The vendor case checks the real resolved provider path in the EGL log.

All six cases passed against the final packaged library (SHA256 6c8de88d01a2a3a7a61a95aa1e3a98b26d37dcc67d916a2302fb41c05f050fd3). This tests the vendor ABI, actual GL stubs and TLS with inert sentinel functions. No EGL display or real context is created, and no hardware drawing or presentation is exercised.

Run with a new output directory from the maintenance project root:

```sh
python3 maintenance/desktop/test-egl-gl-dispatch.py \
 --baseline builds/desktop-userland-fix7-20261104/egl/libEGL_mesa.so.0 \
 --candidate builds/desktop-userland-fix8-20261106/egl/libEGL_mesa.so.0 \
 --output work/my-gl-dispatch-replay
```
