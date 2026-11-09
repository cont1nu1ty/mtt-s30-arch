# MTT S30 第四轮实测：初始化和接口枚举通过

核验日期：2026-10-30。测试目录 `20261029-235643`。本轮模块 `db8e4393ec50e0e2542dafdb7277240627406b847dc19d0427444712249143bb`，内核 `7.2.11-arch1-1`。已读取 root 导出的完整测试日志和恢复结果。

## 实测结果

| 检查 | 结果 |
| --- | --- |
| 模块加载 | insmod=0，耗时 0.966 秒；PCI 04:00.0 绑定 mtgpu，renderD128 出现 |
| 工作队列修复 | 本轮新增日志未出现原 __alloc_workqueue WARNING |
| 显示关闭修复 | 三个 DISPC 均在注册 IRQ 前完成固件显示交接；原 DISPC-2 stop 超时消失 |
| 显示输出初始化 | HDMI 配置为 1920×1080、60 Hz，fbcon 交给 mtgpudrmfb；未启动加速 KDE |
| VPU 映射修复 | 记录 BAR0+0x108000、size 0xe000；原资源冲突和 mapping multiple BARs 消失 |
| 管理工具 | 返回 0；识别 MTT S30、驱动 3.1.0、2048 MiB、PCIe 8x；该时刻温度 56°C |
| Vulkan | 返回 0；MTT S30、1ed5:0102、离散 GPU，设备 API 1.3.225；排除了软件渲染器 |
| VA-API | 返回 0；加载 Mthreads VPU driver for MTT S30，列出视频 profiles/entrypoints |
| 内核检查 | 初始化和三项用户态枚举后，既有严格故障扫描无命中 |
| 恢复 | 正常重启请求于 10 月 29 日 23:59:56；10 月 30 日 00:00:37 已进入原系统；root 核验 True |

本次 EFI 共 11 个文件，10 个内容不变，仅 `loader/random-seed` 正常轮换，没有新增/删除。当前 KDE 正常，mtgpu 未安装到系统、未随开机加载，watchdog inactive，临时固件路径恢复为空。

## 本轮边界和额外日志

本轮证明内核初始化、控制台显示配置和用户态接口枚举可用，尚未执行实际 Vulkan/OpenGL 渲染、视频编解码或加速 KDE。VA-API 列出的格式只是驱动宣告的能力，不能当作这些格式均已实际硬件解码/编码成功。Vulkan 日志中实例版本 1.4.363 来自系统 loader，S30 设备 API 是 1.3.225。

Vulkan loader 的 NVIDIA 层禁用提示来自测试环境显式禁用外部 layers；DISPLAY/XDG_RUNTIME_DIR 提示出现在无桌面环境中，surface 信息未测试。设备枚举和 S30 身份核验成功，不能据此宣称窗口系统集成已通过。

23:58:57 存在一次 `clocksource: Watchdog remote CPU 4 read timed out`。同类记录在前两次启动的显卡加载前，以及本次重启后尚未加载 mtgpu 时也存在，见 `clocksource-baseline.log`；当前证据不足以归因于显卡，也不把它删除或称整段日志完全无异常。模块未签名造成的内核 taint 仍存在。

监督服务在正常重启阶段出现 stop-sigterm timeout/SIGKILL，与已有保留 watchdog 等待的退出策略一致；日志明确记录由该服务请求正常重启，不是 GPU 崩溃或硬件 watchdog 到期复位的证明。硬件倒计时/喂狗已检查，实际到期复位仍未单独验证。

闭源核心的 objtool 告警仍未解决；本次短时成功不能证明长期稳定性或所有内核缓解机制兼容。LTS 仍仅构建通过，未启动或加载实测。

## 后续验收

先完成小规模真实 GPU 渲染/计算结果校验，以及短视频硬解码与软件解码结果对照，再进入隔离的 KDE/Wayland 测试与持续运行、休眠恢复检查。继续使用临时加载和原启动配置回退；当前不持久安装。

原始导出：`/var/tmp/mtt-s30-results-20261029-235643`。关键证据已复制至 `maintenance/validation/runtime-20261029-235643/`，此前候选构建和失败测试记录均保留。
