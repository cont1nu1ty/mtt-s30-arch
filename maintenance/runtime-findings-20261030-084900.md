# MTT S30 第五轮实测：真实渲染、H.264 硬解和恢复通过

核验日期：2026-10-30（Asia/Shanghai）。测试目录 `20261030-084900`，内核 `7.2.11-arch1-1`。已读取 root 导出的完整日志、图像/视频原始输出和 EFI 恢复结果，并重新核对输出内容。本轮沿用模块 `db8e4393ec50e0e2542dafdb7277240627406b847dc19d0427444712249143bb`，没有新增内核源码修复。

## 结果与证据

| 检查 | 实测结果 |
| --- | --- |
| 加载与枚举 | insmod=0；04:00.0 绑定 mtgpu，renderD128；管理工具、Vulkan 和 VA-API 均通过 |
| Vulkan 实际绘制 | S30 模式，设备 1ed5:0102；8 帧 128×96 图像，98,304 个像素全部匹配，零差异 |
| H.264 实际硬解 | 320×192、24 fps、48 帧 High Profile 测试流；48 帧全部为 VAAPI 硬件帧，零错误帧、零差异字节 |
| 导出后独立复核 | Python 重新核对最后一帧全部 RGBA 像素；完整 4,423,680 字节 NV12 输出与预先生成的 CPU 参考一致 |
| 制品身份 | 工作负载 manifest 与固定哈希一致；当前 runner/support 源码哈希与 root 暂存记录一致 |
| 内核新增日志 | 加载后至关机的 journal 故障扫描无命中；原 workqueue WARNING、DISPC 停止超时和 VPU 映射冲突未复现 |
| 重启 | 08:52:12 由 mtt-s30-once.service 请求正常重启，08:52:57 新启动日志开始 |
| EFI 恢复 | 核验 True；11 个文件中 10 个完全一致，仅 loader/random-seed 轮换，无增加或删除 |
| 当前状态 | 原内核和 KDE 正常，mtgpu 未加载、未持久安装；watchdog inactive，临时固件路径为空 |

渲染程序每帧改变颜色排列，通过图形管线、着色器和 vkCmdDraw 绘制后读回。日志逐帧记录每帧 12,288 像素匹配；保留的最后一帧由 Python 再生成预期图案核对。视频程序强制 VAAPI 格式，逐帧检查硬件帧上下文，并拒绝软件回退。测试绑定的 render 节点属于 S30，VA-API 日志识别 Mthreads VPU driver for MTT S30。

渲染输出 SHA256：`f6b5fea7be1327ca395fb1e22b7a3a3b813ac4edcc8c568e8102d0670dabaedd`。

完整解码输出与 CPU 参考 SHA256：`71bc2ca60616df175a713a32e904a759ecf4b46982a3d352d68c9d7c40756b3c`。

本轮渲染命令耗时约 0.365 秒、视频命令约 0.114 秒，均包括进程和接口初始化；这些短任务时间不能作为 FPS、吞吐或持续性能结论。

## 日志解释与恢复边界

完整 dmesg 包含此前启动时的 SRSO/think_lmi 告警，发生于 00:00，早于本轮 08:49 加载。判断本轮故障使用加载前后的日志边界及测试时段 journal，没有将整份历史日志当作新增问题。未签名模块引起的内核 taint 仍存在。Vulkan loader 报告主动禁用 NVIDIA layers，DISPLAY 未设置导致 surface 信息略过；这些不是本轮离屏绘制失败，也不构成窗口系统验证。

监督进程在重启阶段保留 watchdog 等待，因此出现 stop-sigterm timeout/SIGKILL 和 watchdog did not stop。journal 明确记录正常重启请求，不能将这些信息当作 GPU 崩溃，也不能把成功重启称为硬件 watchdog 到期复位已验证。另观察到 systemd-shutdown 接管 watchdog 后使用现有 10 分钟超时；监督阶段的 60 秒设定不代表整个关机过程均保持 60 秒。本轮没有修改该配置。

## 适配状态与下一阶段

本轮证明这台 S30 在该内核上能够完成所测 Vulkan 绘制和 H.264 硬解，并输出正确结果。加速 KDE/Wayland、OpenGL/EGL/GBM 桌面集成、其他视频格式和编码、计算任务、长时间运行以及休眠恢复仍未验证。LTS 仍仅构建通过；闭源核心 objtool 告警与内核缓解机制兼容问题仍保留。

下一阶段是隔离的 KDE/Wayland 会话验证：先检查 EGL/GBM 和 OpenGL 硬件 renderer，再验证合成器、窗口呈现和退出恢复，继续使用临时加载与现有启动配置。当前 `--workloads` 入口只执行本轮负载，不能当作 KDE 测试入口。

原始导出：`/var/tmp/mtt-s30-results-20261030-084900`。完整副本、独立复核结果、测试至关机 journal 和证据哈希清单位于 `maintenance/validation/runtime-20261030-084900/`。此前失败、修复、第四轮枚举结果及软件自检记录均保留。
