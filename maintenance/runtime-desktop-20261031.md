# 第六轮准备：隔离 KWin/Wayland、EGL/GBM 和窗口呈现

本页是原第六轮设计。当前重试请按 [第七轮修复说明](runtime-userland-fix1-20261031.md)，使用已构建验证的 `kwin-wayland-v2` 私有组件。

准备日期：2026-10-31。**本轮现已执行，整体失败并成功恢复**：EGL/GBM 绘制通过、KWin 使用 S30，但原生 Wayland 客户端失败；还发现 KWin shader / EGLImage 错误。参见 [实测结果及修复状态](runtime-findings-20261031-191508.md)。下文是原测试设计和准备记录；下一轮用户态修复尚未就绪，不应重复原桌面命令。本轮沿用同一个 `db8e4393ec50e0e2542dafdb7277240627406b847dc19d0427444712249143bb` 内核模块。

升级复核：用户随后将 KWin/Mesa 更新为 6.8.2-1 / 1:26.2.6-1。旧入口在退出桌面前正确拦截；已完成源码差异审阅、新版软件参考会话和 40 项流程测试，并更新版本检查。详见 [升级复核记录](desktop-upgrade-review-20261031.md)。

## 测试内容和通过条件

1. 新建 EFI/启动基线备份，校准 watchdog，停止当前桌面并等待 DRM 使用者退出。保持原临时加载流程和 ESP 只读保护。
2. 复测模块初始化、管理工具、Vulkan/VA-API 枚举，以及第五轮的 8 帧 Vulkan 绘制和 48 帧 H.264 硬解。
3. 使用 S30 的 render 节点及厂商 GBM/EGL 库建立 GLES 3 上下文。实际绘制 8 帧 256×192 图像，逐像素比较，保存最后一帧供 Python 再次核对。要求渲染器明确包含 S30，拒绝 llvmpipe/softpipe。
4. 启动独立 D-Bus 上的 KWin 6.8.2，通过真实 DRM 后端使用 S30 的 KMS 节点。要求 D-Bus 服务属于新建的 KWin 进程、进程实际打开该节点、合成器使用 S30 EGL/OpenGL ES、HDMI/DP 物理输出启用且尺寸非零。
5. 在该会话中显示色块测试窗口，绘制 60 帧；每帧读回并核对全部像素，共 2,949,120 个像素。逐帧等待 Wayland presentation-time 呈现反馈，要求 60 次呈现、零丢弃，并记录硬件反馈标志。再次检查合成器状态，关闭测试会话，核对内核日志。

测试关闭直接扫描输出，以便窗口经过合成器。厂商库选择仅在测试进程中生效，KWin 使用独立 HOME、XDG 配置/缓存/运行目录，不读取或覆盖当前用户桌面配置。只启动 KWin 和专用 GLES 测试客户端；尚不启动完整 Plasma、Xwayland 或用户应用。

presentation-time 的硬件标志不能单独证明真实显示：本机 KWin 在虚拟后端同样给出这些标志。因此验收必须同时检查 S30 渲染器、DRM 后端、KMS 文件描述符和已启用的物理输出。客户端像素比较证明其绘制/读回正确，呈现反馈证明合成器报告已呈现；本轮没有采集最终扫描输出像素，不能据此断言显示器颜色、合成效果和全部桌面功能均正确。

## 已完成的本地验证

- C 工具以 `-Wall -Wextra -Werror` 编译，使用本机 Wayland 协议 XML 生成客户端代码；manifest 固定可执行文件及源码/协议哈希。
- 在软件 surfaceless EGL 上完整绘制并读回 8 帧，通过。
- 在独立虚拟 KWin 上运行完整窗口流程：60 帧、2,949,120 像素零差异，60 次呈现、零丢弃；窗口关闭后合成器仍正常，受控退出完成。
- 故意将着色器红色改为半亮度，工具在第 0 帧第 0 个像素返回错误；指定非 mtgpu 设备被拒绝；真实的软件运行输出被硬件验收规则拒绝。
- 38 项恢复/负载/桌面流程测试通过，包括新制品校验、隔离环境、防软件/虚拟输出误报、像素损坏、前置失败阻止 KWin、制品错误阻止退出工作桌面、合成器图形错误识别，以及旧恢复行为。
- 在厂商私有库搜索环境下核对 KWin、测试程序和 GBM 后端依赖，无缺失；KWin 命令行入口正常。

软件自检中发现并修正了两个测试流程假设：虚拟后端报告名为 `KWin::VirtualBackend`；KWin 的 SIGTERM 处理执行 Qt 正常清理后返回正数 15。入口仅在检查全部通过、由监督程序主动终止且没有强制杀进程时接受该退出码，负数 -15 或 SIGKILL 不算成功。此外 KWin 禁止普通用户读取其 fd 表，软件自检不以此证明设备绑定；root 硬件测试仍严格要求 fd 绑定证据。

依据：[KWin 6.8.1 主入口及退出处理](https://github.com/KDE/kwin/blob/v6.8.1/src/main_wayland.cpp)、[DRM 后端](https://github.com/KDE/kwin/blob/v6.8.1/src/backends/drm/drm_backend.cpp)、[合成器信息](https://github.com/KDE/kwin/blob/v6.8.1/src/workspace.cpp)、[呈现反馈实现](https://github.com/KDE/kwin/blob/v6.8.1/src/wayland/presentationtime.cpp)。源码片段保存在 `work/desktop-research-20261031/`；本地自检证据位于 `maintenance/validation/desktop-preparation-20261031/`。

## 启动与恢复

保存全部工作后，在自己的终端运行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

这会退出当前 KDE。通过前置检查后会短暂显示测试窗口，随后关闭测试会话，在监督阶段约 3 分钟后请求重启。重启后仍回到原启动配置。当前执行器没有免密 sudo，因此需要用户在自己的终端输入密码。

EGL/GBM 命令上限 20 秒；独立 KWin 阶段上限 75 秒，内部启动等待 20 秒、客户端 20 秒、退出等待 8 秒，必要时强制终止并判失败。保留 60 秒 watchdog 喂狗和 210 秒备用重启计时器。正常关机后 systemd 可能按现有配置接管 watchdog 并设置为 10 分钟；硬件到期复位仍未独立验证，不能保证恢复所有硬件挂死。

不修改内核、initramfs、启动项、驱动自动加载或全局图形库。KWin/Mesa 必须仍为已复核的 `6.8.2-1` / `1:26.2.6-1`；变化时在创建新备份前停止并提示具体版本，暂存后及退出桌面前再次核验。工作负载清单 SHA256 为 `65cb6f8b6d0ed8403c26ff79f8fe9f649b91e4ba2fd3352bf8ee5815505de1f9`。当前 `--workloads` 入口保留，仍只执行第五轮负载。

本轮摘要的 profile 为 `kwin-wayland-v1`，完整成功阶段为 `desktop_checks_passed`。单独的 `workload_checks_passed` 只表示前面的 Vulkan/H.264 通过。日志导出器已包含 GBM、KWin、Wayland 客户端、像素输出及桌面结果；重启后按本轮新目录导出并复核。

通过后再验证完整 Plasma/Xwayland、实际应用、持续运行和休眠恢复；闭源核心的 objtool 与缓解机制兼容问题没有因本轮准备而消失。
