# 第七轮结果及第八轮准备

2026-11-03。**第七轮整体未通过：原生 Wayland 客户端在 DRI screen 创建阶段失败。新修复已完成本地验证；随后已确认 7.2.14 普通启动与桌面恢复，下一步创建新的恢复备份并审计，不能复用旧测试目录。**

## 第七轮真实结果

- 测试目录 `20261103-094436`，profile `kwin-wayland-v2`，运行内核 `7.2.11-arch1-1`。
- 模块加载、Vulkan 8 帧/98,304 像素、H.264 48 帧硬解、EGL/GBM 8 帧/393,216 像素通过。导出后独立核对保存的图像及完整视频字节通过。
- 私有 KWin 与 `libkwin` 路径验证通过，renderer 为 MTT S30，使用真实 DRM/HDMI 输出。
- 第六轮的着色器编译和 EGLImage 导入错误在本轮启动及受控退出路径中没有再出现；客户端没有提交成功窗口，因此不能据此声称所有窗口导入问题已经解决。
- 新 EGL 已通过 dma-buf feedback 发现显卡并打开厂商 `mtgpu_dri.so`，随后报 `egl: failed to create dri2 screen`、`EGL initialization failed (EGL=3001 GL=0)`。没有完成窗口绘制。
- 从模块加载至关机的 journal 核验未发现新增内核故障。模块加载前的 WPS `QingWorkThread` 异常不归入显卡驱动结果。
- 09:47 请求正常重启；重启后桌面正常、mtgpu 未加载、临时服务和 watchdog inactive。监督服务关机时被 systemd 超时终止是其保留 watchdog 的既定退出方式，不能据此认定 GPU 挂死。

证据：[analysis.json](validation/runtime-20261103-094436/analysis.json)、[逐文件校验](validation/runtime-20261103-094436/evidence-sha256.json)。旧运行日志和原始 `Recovery verification: False` 均保留。

## 为什么恢复比较失败

pacman 日志显示，**在测试重启之后**，09:53 的系统升级将 linux/linux-headers 从 7.2.11 更新到 7.2.14，并更新 Qt Declarative 为 `6.12.0-4`。旧 EFI 基线的五个 7.2.11 文件被删除，新增对应的五个 7.2.14 文件；随机种子也轮换。

这不是允许忽略的随机种子变化。旧基线整体比较继续标记失败，不回滚用户升级，也不将新增/删除启动文件放入白名单。

独立 root 只读检查已确认：新的默认项为 7.2.14，正常/备用 initramfs 存在且只含 7.2.14 模块，不含 mtgpu；两个启动项的内核哈希都与安装的内核一致，root 参数保持一致，无待执行 EFI 覆盖。检查脚本为 `recovery/inspect-next-boot.py`，记录为 [upgraded-boot-files.json](validation/runtime-20261103-094436/upgraded-boot-files.json)。

上述只读检查时仍运行 7.2.11。随后普通重启已确认进入 7.2.14，桌面 active、mtgpu 未安装/未加载、watchdog 和临时测试单元 inactive；版本、模块与修复包哈希通过：[本次启动核验](validation/normal-boot-7.2.14-20261103/verification.json)。新 root EFI 备份及当前/默认启动项审计仍须由受控入口执行。旧 EFI 比较结果继续保留失败，不恢复旧备份覆盖系统升级。

## 已完成的修复

### Wayland：提供厂商能接受的图像查找接口

同版本 Ubuntu Mesa EGL 提供 `DRI_IMAGE_LOOKUP` v2，但原厂 3.1.0 DRI 库在 screen 创建入口只接受 v1；v2 会在任何 DRM 初始化之前直接返回失败。

已用同一厂商二进制完成两个无 GPU 初始化的调试对照：v2 到达拒绝分支，v1 到达检查通过分支。进一步让新编译 EGL 的真实 v1 回调表进入该厂商入口，同样通过检查；断点处立即终止进程，未继续设备初始化。该结果确认了一个具体兼容障碍，不代表后续所有硬件调用均已通过。

补丁只为 Wayland `mtgpu` 提供完整 v1 接口，其 `lookupEGLImage` 继续调用原有带 EGLImage 校验的函数；其他驱动仍使用 v2。保留 DRI_Mesa 版本检查，没有修改闭源用户态或内核核心。

私有 EGL 从准确的 Ubuntu `23.2.1-1ubuntu3.1~22.04.3` 源包重建；版本生成遵循该源包 `debian/rules`，不是将其他版本伪装为它。源码归档和发行版补丁的哈希均经已签名快照 Sources 索引验证。另包含 Python 3.12 构建检查适配，以及 Mesa 上游 [C23/glibc once_flag 修复](https://gitlab.freedesktop.org/mesa/mesa/-/commit/179e744f7577d98df7c79d7324c22acfb32a0154)。

来源参考：[Ubuntu 快照](https://snapshot.ubuntu.com/ubuntu/20250516T000000Z/dists/jammy-updates/InRelease)、[Mesa EGL 文档](https://docs.mesa3d.org/egl.html)。版本相同本身不足以证明厂商扩展都兼容；本轮因此增加了真实回调分支对照。

### 新内核与候选制品

- 为 `7.2.14-arch1-1` 从官方原包和既有兼容补丁干净重建模块，构建/链接通过，832 个外部符号均在目标 `Module.symvers` 中，14 项源码回归通过。
- 模块 SHA256：`6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff`。闭源核心未改动，仍有 5,486 条 objtool 警告；新内核实际加载和长期稳定性未验证。
- 新 profile：`kwin-wayland-v3`，目录 `builds/desktop-userland-fix2-20261103`。
- Manifest SHA256：`b6239318bb23252b36bdfa85472984a069119e669105ac006ad11b7734672885`。
- 沿用已在第七轮启动成功的私有 KWin；仅替换私有客户端 EGL，补充失败时的加载库诊断。硬件验收还必须确认 lookup-v1 分支标记。
- 更新后的 Qt Declarative 环境中，私有 KWin+EGL 软件窗口 60 帧、2,949,120 像素零差异、60 次呈现、零丢弃；独立核对保存像素通过。软件结果不计为 S30 实机通过。
- 47 项恢复/桌面/负载流程测试通过。新制品的根目录暂存形状、哈希、依赖及无嵌入 RPATH/RUNPATH 均已核验。

补丁：[mesa-23.2.1-mtgpu-image-lookup-v1.patch](../patches/mesa-23.2.1-mtgpu-image-lookup-v1.patch)；重建工具：`desktop/build-egl-compat.py`。构建命令、软件记录、真实回调对照和来源校验见 [validation.json](validation/userland-fix2-20261103/validation.json)。

## 下一轮边界

**7.2.14 普通启动已确认，下一步通过受控入口创建新恢复基线并测试。** 准备脚本固定 7.2.14 和新模块哈希，继续拒绝其他内核。使用 `prepare-and-test.py --start --desktop` 创建全新备份并启动受控测试；运行前保存工作，避免同时升级系统。

恢复机制继续保持：不安装/自动加载 mtgpu，不修改内核、initramfs、启动项和系统图形库；GPU 测试期间 ESP 只读；watchdog 校准、180 秒正常重启和 210 秒备用计时器。硬件 watchdog 到期复位仍未经独立验证，严重挂死可能需人工重启。

本轮未执行新修复的 S30 窗口、完整 Plasma/Xwayland、最终扫描输出截图、长时间运行或休眠恢复测试。
