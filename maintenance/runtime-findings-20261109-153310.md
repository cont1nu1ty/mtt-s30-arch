# v10 已通过 S30 隔离 KWin 与原生 Wayland 实测

2026 年 11 月 9 日 15:33 的 `20261109-153310` 在内核 `7.2.14-arch1-1` 上完成 `kwin-wayland-v10` 测试。原生客户端通过 60 帧硬件呈现和像素比较，随后成功销毁 EGL 窗口、上下文和 Wayland 连接，以退出码 0 结束。KWin 在客户端退出后继续使用 S30 驱动 HDMI。计划重启与 EFI 恢复核验通过。[本轮分析](validation/runtime-20261109-153310/analysis.json) · [完整桌面测试结果](validation/runtime-20261109-153310/desktop-result.json)

## 窗口销毁修复的实机结果

本轮使用 v10 已审阅的八个制品。客户端加载了私有 EGL、修复后的主 DRI 库及原版次级 DRI 库。主库 SHA-256 为 `05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23`。运行库路径与暂存目录相符，导出的 manifest 与构建制品一致。原生客户端识别为 `MOORE THREADS / MTT S30`，两个进程均使用真实设备。[制品清单](validation/runtime-20261109-153310/desktop-manifest.json) · [输出与库路径复核](validation/runtime-20261109-153310/output-verification.json)

v9 在第 60 帧后进入 `eglDestroySurface` 时重复析构。v10 的协议日志继续记录了缓冲、xdg 窗口、Wayland surface 和呈现对象销毁，随后同步回调成功，并输出最终成功 JSON。固定版本测试程序在全部 EGL 清理和连接清理成功后才会写出该记录。客户端退出码为 0，本轮客户端的 SIGABRT/SIGSEGV 查询为空。KWin 的后续状态查询成功，最终按监督程序请求以 15 退出，未使用强制终止。[客户端日志末尾](validation/runtime-20261109-153310/wayland-client.log) · [客户端退出后的 KWin 状态](validation/runtime-20261109-153310/kwin-support-after.log) · [v9 故障与两条指令修复](runtime-findings-20261109-150112.md)

## 实际负载与独立复核

| 路径 | 本轮运行检查 | 导出后的独立核验 |
| --- | --- | --- |
| Vulkan | 8 帧，98,304 个像素，零差异 | 末帧 12,288 个 RGBA8 像素逐字节匹配 |
| EGL/GBM | 8 帧，393,216 个像素，零差异 | 末帧 49,152 个 RGBA8 像素逐字节匹配 |
| 原生 Wayland GLES | 60 帧，2,949,120 个像素，零差异 | 末帧 49,152 个像素匹配，60 组呈现请求与回调逐项配对 |
| H.264 VA-API | 全部 48 帧硬件解码 | 4,423,680 字节与固定参考及本次重新软件解码均一致 |

60 个呈现回调的时间戳严格递增，标志均为 7，丢弃帧数为 0。KWin 在 HDMI-A-1 上选择了 1920×1080 的 XR24 输出。独立图像比较覆盖各路径保存的末帧，前序帧依据实机测试程序逐帧检查及最终成功结果。像素来自客户端帧缓冲，物理 HDMI 扫描输出尚未单独捕获。[复核脚本](validation/runtime-20261109-153310/verify-outputs.py) · [复核结果](validation/runtime-20261109-153310/output-verification.json)

## 启动恢复与验证范围

mtgpu 于 15:33:57 初始化，模块加载至关机的既定内核故障筛查为空。临时测试服务于 15:36:23 发起计划重启，当前启动时间为 15:37:01。EFI 共 11 个文件，仅 `loader/random-seed` 正常轮换，其余 10 个一致。当前 KDE 已恢复，mtgpu 未加载或安装，测试服务、计时器和 watchdog 均 inactive。watchdog 超时复位仍待单独验证。[内核与重启核验](validation/runtime-20261109-153310/boot-review.json) · [受保护的 EFI 恢复结果](validation/runtime-20261109-153310/recovery-result.json)

启动日志仍包含 `swrast` 加载、`EGL_NOT_INITIALIZED` 和 PipeWire 连接消息。固定版本源码中，KWin 会预先尝试创建软件渲染设备，录屏插件也会连接 PipeWire。结合本轮私有库目录和独立运行目录，这些路径能够解释上述消息，具体 EGL display 的对应关系尚缺运行时追踪。本轮随后建立的 S30 输出、渲染、清理与恢复均通过验收，日志中的残余消息继续保留。[原始 KWin 日志](validation/runtime-20261109-153310/kwin.log)

本次范围为单个隔离 KWin 会话和一个原生 GLES 窗口。完整 Plasma、XWayland、重复开关窗口、长期运行、休眠唤醒及 LTS 实测仍待开展。v10 离线对照中，原版与修复版库卸载时均留下 22 项共 74,268 字节分配，实际持续运行的影响尚待测量。后续测试继续使用新的恢复基线。[本地卸载对照](validation/userland-fix9-20261109/lifetime/results.json) · [受控测试入口](recovery/README.md)
