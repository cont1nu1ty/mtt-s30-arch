# v11 已通过五轮窗口生命周期与 Qt Quick 实测

2026 年 11 月 9 日 16:08 的 `20261109-160826` 在 `7.2.14-arch1-1` 上完成 v11 验收。S30 连续完成五轮窗口、上下文与 Wayland 连接创建和销毁，共 300 次硬件呈现；随后 Qt Quick 程序通过 12 帧 GLES 绘制。两个客户端均正常退出，导出后的图像、视频和启动恢复独立复核通过。[本轮分析](validation/runtime-20261109-160826/analysis.json) · [输出复核](validation/runtime-20261109-160826/output-verification.json)

## 本轮实际测试

本轮沿用 v10 的内核和用户态修复，新增重复生命周期与 Qt Quick 负载。九文件制品清单 SHA256 为 `8b6f7a9f028bac894b34a206b17a9755470e45b88e5e2b923122eab64cd18f64`，与导出的暂存配置一致。两个客户端均加载私有兼容 EGL、修复后的主 DRI 和原版次级 DRI，并报告 `MTT S30`。整个私有 KWin 会话约 17.8 秒。[本轮准备](runtime-applications-v11-20261109.md) · [制品清单](validation/runtime-20261109-160826/desktop-manifest.json)

| 路径 | 本轮运行检查 | 导出后的独立核验 |
| --- | --- | --- |
| Vulkan | 8 帧、98,304 个像素，零差异 | 末帧逐字节匹配 |
| EGL/GBM | 8 帧、393,216 个像素，零差异 | 末帧逐字节匹配 |
| 原生 Wayland GLES | 五轮各 60 帧，共 300 次硬件呈现、14,745,600 个像素，零差异 | 五轮请求/反馈各自完整配对，全部标志为 7，跨轮时间戳递增，末帧匹配 |
| Qt Quick GLES | 12 帧、589,824 个像素，零差异，12 次交换 | RGBA 末帧与公式匹配，PNG 解码后内容相同 |
| H.264 VA-API | 48 帧全部硬件解码 | 4,423,680 字节同时匹配固定参考及本次重新 CPU 解码 |

五轮原生客户端日志均在窗口、缓冲、呈现对象清理和同步回调完成后记录该轮结束。Qt 日志在窗口和整个应用的 Wayland 对象清理之后才输出最终成功 JSON。两个进程退出码均为 0，无匹配的 SIGABRT/SIGSEGV 崩溃记录。KWin 在客户端退出后仍报告 S30 / HDMI-A-1 / 1920×1080，最后按请求以 15 退出，没有强制终止。[原生客户端日志](validation/runtime-20261109-160826/wayland-client.log) · [Qt 客户端日志](validation/runtime-20261109-160826/qt-client.log) · [客户端退出后 KWin 状态](validation/runtime-20261109-160826/kwin-support-after.log)

独立图像比较覆盖各路径保存的末帧，其余帧依据固定版本测试程序的逐帧检查及正常退出。Qt 的交换/读回不等于独立硬件呈现反馈；本轮硬件呈现计数来自原生 EGL 客户端。未捕获物理 HDMI 扫描输出像素。[复核脚本](validation/runtime-20261109-160826/verify-outputs.py)

## 恢复与剩余范围

16:09:13 加载 mtgpu 后，至关机未匹配到新增 GPU/内核故障。16:11:40，测试服务内的 systemctl 发起计划重启，16:12:19 进入当前启动。监督服务在关机时被 SIGKILL，符合原有十秒停止超时策略，不作为显卡挂死证据。[内核和重启分析](validation/runtime-20261109-160826/boot-review.json)

EFI 共 11 个文件，仅 `loader/random-seed` 正常轮换，其余 10 个一致，无新增或删除。当前显示管理器 active，临时服务、计时器和 watchdog inactive；mtgpu 未安装、未加载，固件临时路径已清空。本轮属于计划重启，仍未证明 watchdog 超时复位。[EFI 复核](validation/runtime-20261109-160826/recovery-result.json) · [当前状态](validation/runtime-20261109-160826/current-state.json)

KWin 启动时仍保留 swrast、EGL_NOT_INITIALIZED 与 PipeWire 连接消息，未被隐藏。此前对可选软件 EGL 设备和隔离 PipeWire 环境的解释仍是源码与日志顺序推断，没有新增逐个 EGLDisplay 的运行追踪。后续 S30 渲染与退出通过，不能据此把这些消息改写为已彻底修复。[KWin 原始日志](validation/runtime-20261109-160826/kwin.log)

本轮补齐了短时重复生命周期与实际 Qt Quick GLES 程序验证。完整 Plasma 默认的桌面 OpenGL 路径、XWayland、持续运行、休眠唤醒和 LTS 实测仍未完成。Arch 内核包仍仅完成本地构建与私有 DKMS 构建，完整用户态部署、安装/卸载/升级恢复和公开授权范围待处理；尚不能作为日常使用的完成版发布。[Arch 包现状](arch/README.md)
