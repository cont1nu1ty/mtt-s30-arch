# 11 月 5 日 v8 实测通过 KWin 启动，Wayland 客户端停在首次 GLES 查询

2026 年 11 月 5 日 14:40 的 `20261105-144027` 实测使用 `kwin-wayland-v8` 和 `7.2.14-arch1-1`。**KWin 在 S30 上成功创建真实 HDMI 输出，原生 Wayland 客户端也成功创建窗口并绑定 EGL 上下文。客户端在绘制首帧之前以退出码 2 结束，整轮桌面测试判定失败。** 11 月 6 日导出并复核了本轮的受保护日志及恢复结果。[本轮独立核验](validation/runtime-20261105-144027/analysis.json)

## 显示与客户端

KWin 实际接受了 `AB24`、`AR24`、`GR88`、`R8`、`RG16`、`XR24` 六项格式。固定驱动表在实机排除了上次查询中的 `XB24` 和 `AB30`，HDMI-A-1 选用了 1920×1080 的 `XR24` 正常无复制 DRM 缓冲。KWin 原有图形错误检查通过。[KWin 日志](validation/runtime-20261105-144027/kwin.log)

客户端加载了本轮私有 EGL、`mtgpu_dri.so` 和 `musa_dri.so`。display 桥接已在实机进入。测试程序对 `eglCreateContext`、`eglCreateWindowSurface`、`eglMakeCurrent` 三步各自检查返回值，并全部通过。随后 `glGetString(GL_RENDERER)` 与 `glGetString(GL_VENDOR)` 至少有一次返回空指针，触发 `Missing GLES identity (EGL=3000 GL=0)`。这两个查询共用一条错误消息，具体哪个值为空仍待区分。绘制及呈现均为 0 帧。[客户端日志](validation/runtime-20261105-144027/wayland-client.log) · [检查位置](desktop/egl-check.c#L157)

14:41:18 的内核日志记录驱动清理 `egl-check` 进程 247535 的应用内存上下文。自模块加载至关机的内核故障筛查通过。客户端退出码为 2，KWin 按测试程序的 SIGTERM 请求退出。追踪 GLES 身份查询需要进一步核对调用的分发入口与线程上下文。[内核日志](validation/runtime-20261105-144027/journal-kernel-postload.log) · [会话结果](validation/runtime-20261105-144027/desktop-session-result.json)

## 基础负载与启动恢复

Vulkan 绘制 8 帧、检查 98,304 个像素。H.264 通过 VA-API 硬解 48 帧，导出的全部 4,423,680 字节与 CPU 参考逐字节一致。EGL/GBM 使用 S30 绘制 8 帧、检查 393,216 个像素。两项渲染均独立复核了保存的最后一帧。归档包括 39 个带 SHA256 的证据文件。[负载记录](validation/runtime-20261105-144027/workload-result.json) · [文件校验清单](validation/runtime-20261105-144027/evidence-sha256.json)

14:43:40 进入计划重启，14:44:21 进入当前启动。测试前后的 boot ID、测试制品 manifest、内核版本及 root 导出的 EFI 校验相互一致。EFI 共 11 个文件，仅 `loader/random-seed` 正常轮换，另外 10 个文件与备份一致。重启后显示管理器 active，mtgpu 已卸载，临时服务、计时器和 watchdog 均 inactive。watchdog 超时复位和完整 Plasma 会话仍待验证。[恢复结果](validation/runtime-20261105-144027/recovery-result.json)

## 11 月 6 日的修复候选 v9

私有 Mesa EGL 原先使用 `_glapi_get_proc_address` 来查找 GL 函数。厂商 DRI 在绑定上下文时将实现登记在 `musa_glapi_set_dispatch` 管理的线程分发表中。两者使用各自的线程数据。离线回放通过旧私有 EGL 的真实 GLVND 回调预取函数地址，再给厂商线程分发表绑定测试实现，重现了旧库身份查询返回空值。实机日志只记录了两个查询共用的失败条件。有关回调定义见 [GLVND EGL 厂商接口](https://github.com/NVIDIA/libglvnd/blob/master/include/glvnd/libeglabi.h)。

v9 在隔离的 S30 Wayland 客户端启动时选择经哈希核验的厂商 GL 函数库。公开 GL 函数和 EGL 内部的 `glFlush` 使用同一个查询入口。调用地址可提前缓存，各线程随后使用其绑定的上下文。加载检查核对厂商分发库的校验值，并确认驱动使用的库名与客户端路径指向同一文件。[分发补丁](../patches/mesa-23.2.1-mtgpu-gl-dispatch.patch)

最终打包库通过 6 项分发回归，包括旧库反例。回归核对测试程序用到的 29 个 GL 入口，并验证多线程、上下文切换、解绑及错误路径。另有 8 项窗口 ABI 回归与 66 项恢复和桌面流程测试通过。隔离软件窗口呈现了 60 帧，2,949,120 个像素零差异，丢帧数为零。S30 上的首帧、像素和硬件呈现由下一轮实测验收。[v9 制品与本地验证](validation/userland-fix8-20261106/validation.json)

下一轮先保存工作，在自己的终端执行以下命令。入口新建本轮 EFI 备份、复核启动项及 watchdog，再结束 KDE 会话、临时加载驱动并安排重启。

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

本机已验证计划重启后从原启动配置恢复。彻底挂死时仍可能需要在本机手动重启。[恢复步骤](recovery/README.md#失败后的人工恢复)
