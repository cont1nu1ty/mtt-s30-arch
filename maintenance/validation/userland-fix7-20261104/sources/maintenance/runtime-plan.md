# S30 受控加载与恢复计划

**2026-11-04 更新：v7 当前上下文查询仍包含错误格式，KWin 导入失败，客户端未执行；本轮 EFI 恢复通过。** v8 真实导入表约束已完成干净构建、35 项源码/最终库回归、64 项流程测试及 60 帧软件验证。下一步以 `--start --desktop` 创建新恢复基线并实测，见 [最新记录](runtime-findings-20261104-200750.md)。

2026-10-31 当前状态：[第七轮私有 EGL/KWin 修复候选](runtime-userland-fix1-20261031.md) 已准备，45 项流程测试及 60 帧联合软件窗口验证通过，可安排受控硬件测试。最新实际硬件结果仍是 [第六轮](runtime-findings-20261031-191508.md)：Vulkan、H.264 和 EGL/GBM 通过，原生 Wayland 窗口失败并恢复。使用 `--start --desktop` 启动新 profile `kwin-wayland-v2`；第五轮 `--workloads` 入口保留。

上一阶段：第四轮初始化、管理工具、Vulkan/VA-API 枚举及恢复核验通过。详见 [第四轮结果](runtime-findings-20261029-235643.md)。

以下为该轮测试执行前的说明：

最新状态：第四轮候选源码修复与构建完成，测试入口固定到新模块 `db8e4393…49143bb`。14 项源码回归、23 项恢复测试通过；新模块及用户态验证尚未实测。保存工作后按 [恢复入口](recovery/README.md) 开始新的受控测试。详见 [本轮修复及验证](runtime-fix3-20261029.md)。

用户已同意测试并要求保留失败后的启动能力。维护目录 `/home/bull/Documents/mtt-s30-arch`，目标 S30 1ed5:0102 / Linux 7.2.11-arch1-1。每轮使用新的 root 备份目录；旧记录不覆盖。

先完成 [恢复预检](recovery/README.md)，确认 root 专属备份与启动文件完整，再进入本计划。

## 前提

1. 保存工作，能使用本机文本 TTY，并可在黑屏/内核无响应时重启。
2. 停止显示管理器及当前 KDE Wayland 会话，在文本控制台执行。这个动作会中断当前桌面和 Codex GUI，由用户执行已授权的单次测试入口触发。
3. 使用本次干净构建产物，核对 vermagic 与 `uname -r`；加载前再查内核日志和固件路径现值。
4. 明确认识厂商闭源对象的 objtool 警告尚未解决。不关闭 IBT、Retbleed 或其他内核缓解参数；若必须改变这些策略，重新评估，而不是自动执行。

## 测试顺序

第一阶段只测试设备初始化：

- 原始驱动 deb 只作为提取源，不执行其安装/卸载脚本。
- 临时设置 firmware_class 的固件查找路径指向本项目 `official/driver-3.1.0/lib/firmware`，事先记录原值。路径只对本次运行有效；测试结束恢复，重启也会恢复默认。
- 加载 `modinfo -F depends` 列出的内核依赖；再从构建目录加载 mtgpu.ko，使用厂商原有参数 `mtgpu_drm_major=2`。
- 观察内核日志、04:00.0 的绑定、renderD 节点和 mthreads-gmi。若出现 firmware 不匹配、GPU reset、IOMMU fault、Oops、挂起等，停止后续图形验证。
- 不把“insmod 返回 0”当成功；PCI 绑定、渲染节点、初始化日志都要核对。

第二阶段使用进程级环境选择同一个 3.1.0 包内的用户态库，不替换系统 Mesa/GLVND/NVIDIA 库，不复制 Debian 系统配置：

- `maintenance/runtime-check.sh` 设置单个进程的厂商库、EGL JSON、Vulkan ICD、DRI、GBM 和 VA-API 路径。未绑定 mtgpu 时会退出 2，避免把软件渲染误报为成功。
- 在控制台先验证管理工具/Vulkan/VA-API；DISPLAY 不存在时脚本明确说明 OpenGL 桌面测试未执行。
- 确认基础功能后，再用隔离测试会话验证 KDE Wayland / Xwayland。单独设置测试会话环境，暂不写全局环境文件。
- 逐项验证显示分辨率/刷新率、HDMI 音频、OpenGL renderer、Vulkan 设备、视频解码、应用退出、GPU reset，以及休眠恢复。未测项继续标记未测。

## 回退

首次测试不把模块安装进 /usr/lib/modules，不写自动加载配置，不运行 mkinitcpio、不改启动参数。系统重启后仍使用现有启动配置；当前工作目录中的 .ko 不会自动进入启动过程。
若加载成功后显示由 mtgpu 接管，不假设 rmmod 能恢复原 simple framebuffer。发生黑屏或无法安全退出时，使用本地控制台正常重启；内核完全无响应才使用硬件恢复。
若以后决定持久安装，先保留能启动的内核/恢复项、记录文件清单和原配置，再部署 DKMS、固件与用户态。此阶段尚未执行，需要结合测试窗口安排。

## 长期维护

每个内核更新依次执行：目标 headers 干净构建 → 测试 → 警告/ABI 差异审阅 → 非工作会话加载验证 → 图形/视频/恢复回归 → 更新兼容矩阵。
保持一个已实测内核作为回退。不能以“DKMS 编译成功”替代完整兼容验证，也不能承诺未来所有 Arch 内核都自动兼容。
