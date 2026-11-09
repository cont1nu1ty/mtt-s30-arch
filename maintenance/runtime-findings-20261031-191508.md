# 第六轮：恢复通过，GBM 绘制通过，原生 Wayland 客户端失败

后续进展：[第七轮私有 EGL/KWin 修复候选](runtime-userland-fix1-20261031.md) 已完成准备，可安排新的受控测试。下文保留第六轮结果和当时的修复状态。

2026-10-31；测试目录 `20261031-191508`，profile `kwin-wayland-v1`。**本轮整体失败，不能宣布加速桌面适配完成。** 本轮已发现用户态图形兼容问题，重复当前桌面命令不会解决它们；下一轮硬件重试尚未准备完成。

## 已确认结果

| 路径 | 实机结果 | 导出后核验 |
| --- | --- | --- |
| 模块初始化 / 枚举 | 成功，仍为 `runtime-fix3-v2` | 模块 SHA 未改变；加载后至关机的内核故障扫描为空 |
| Vulkan 绘制 | 8 帧，98,304 像素零差异 | 最后一帧独立逐像素核对通过 |
| H.264 VA-API | 48 帧全部硬解，零字节差异 | 完整 4,423,680 字节输出与 CPU 参考一致 |
| EGL/GBM GLES | 8 帧，393,216 像素零差异 | 最后一帧独立逐像素核对通过，renderer 为 MTT S30 |
| KWin DRM 启动 | GLES/EGL 合成器使用 MTT S30，打开 `/dev/dri/card0`，HDMI-A-1 1920×1080 60Hz | 私有 D-Bus PID、DRM 文件描述符和支持信息符合设备绑定要求；这不等于桌面完整通过 |
| 原生 Wayland 窗口 | 客户端返回 2，未开始绘制 | `EGL initialization failed (EGL=3000 GL=0)`；没有成功像素文件或呈现结果 |
| 恢复 | 正常重启，原桌面恢复 | EFI 11 文件中 10 个完全一致，仅 `loader/random-seed` 正常轮换，无增删；Recovery verification=True |

当前内核仍为 `7.2.11-arch1-1`，临时 mtgpu 模块未加载，watchdog inactive。测试后没有安装驱动、替换系统库、改启动文件或安排第二次重启。正常重启不是 watchdog 到期复位证明。

## 错误与证据

### 1. 厂商 EGL 与新版 Wayland 设备发现协议不匹配

硬件日志原来的错误文案同时覆盖 `eglGetPlatformDisplayEXT` 返回空和 `eglInitialize` 失败，因此仅凭该文案不能区分两个调用。

随后进行了不接触实际 GPU 的复现：在独立虚拟 KWin 中使用同一厂商 EGL，协议跟踪显示 KWin 广告 dma-buf v6，厂商库只绑定 v3，没有请求 v4 的设备反馈；服务端没有 `wl_drm`，客户端同样失败。最小 Wayland 服务端对照进一步发现：不提供 `wl_drm` 时厂商库返回空 display；提供 `wl_drm` 并广播一个特意不存在的设备路径时，它立即尝试打开该路径。实验没有使用实际设备或伪造硬件通过结果。

这确认了厂商库依赖旧设备发现路径，与实机失败吻合。**本轮实机未记录协议跟踪，因此还不能声称已经逐条还原实机的全部协议交互。** 下一步应实现支持新设备反馈且兼容厂商 DRI 的 EGL 适配，或审阅 KWin 的旧设备发现兼容实现；之后必须重新实测窗口绘制。不能简单把系统 Mesa 26 的 EGL 替换进去就假定可兼容旧 DRI：其 EGL 已直接使用 Gallium 内部结构，代码路径需单独验证。

### 2. KWin 模糊特效的 GLSL ES 编译错误

KWin journal 记录了 `Failed to compile fragment shader` 和 `Failed to load downsampling pass shader`。提交给驱动的着色器以 `#version 300 es` 开头，却调用了旧的 `texture2D`。独立 `glslangValidator` 对原始提交文本同样报错，说明不能把这条错误简单归因于内核驱动。

已准备 [KWin 6.8.2 源码补丁](../patches/kwin-6.8.2-blur-gles.patch)，仅把下采样着色器的五处 `texture2D` 改成 `texture`；它与同版本上采样着色器的写法一致。补丁无模糊匹配应用通过，并按 KWin 的 ES3 / ES2 预处理路径分别验证通过。**这是源码补丁，尚未重建或替换系统 KWin，也未在 S30 上复测特效。**

依据：[KWin 下采样着色器](https://github.com/KDE/kwin/blob/v6.8.2/src/plugins/blur/shaders/downsample.frag)、[着色器预处理](https://github.com/KDE/kwin/blob/v6.8.2/src/opengl/glshader.cpp)。

### 3. 尚待定位的 EGLImage 导入错误

KWin journal 另有 `Error creating EGLImageKHR: "EGL_BAD_PARAMETER"`。它早于客户端失败，原摘要未收集到；目前还不能判断对应哪个图像、是否发生了回退，以及对最终显示的影响。新检测会保留并判失败，不能把“合成器仍在运行”当作无图形错误。

## 已修复的测试工具问题

- Qt 默认把 KWin 消息写入 journal，旧扫描器只读重定向文件，导致 `compositor_faults=[]` 不完整。现在在私有环境中强制 `QT_FORCE_STDERR_LOGGING=1`，并识别着色器编译/加载及 EGLImage 导入错误。用本轮真实 journal 做了回归测试。依据：[Qt 日志实现](https://github.com/qt/qtbase/blob/v6.12.0/src/corelib/global/qlogging.cpp)。
- 客户端加入 Wayland 协议和 EGL 调试日志；区分 display 创建与初始化失败；顺序保存 EGL / GL 错误，避免 C 参数求值顺序影响诊断。
- 诊断制品更新为 `builds/desktop-diagnostics-20261031`，manifest SHA256 `4baddf374101d1a5fd8094493a31e2bcab09b59395335c90ec10c82b0b73e03c`。已完成 8 帧软件离屏、60 帧虚拟窗口和独立像素检查；41 项恢复/负载/桌面流程测试通过。
- 以上改动修复日志和错误归因，没有降低 S30 渲染器、DRM 设备、物理输出、像素或呈现验收要求；也没有修好闭源 EGL 的 Wayland 兼容问题。

证据归档：[analysis.json](validation/runtime-20261031-191508/analysis.json)、[原始 Wayland 错误](validation/runtime-20261031-191508/wayland-client.log)、[KWin journal](validation/runtime-20261031-191508/kwin-journal.log)、[恢复核验](validation/runtime-20261031-191508/recovery-result.json)。目录附全部文件的 SHA256 清单，前五轮记录保留。
