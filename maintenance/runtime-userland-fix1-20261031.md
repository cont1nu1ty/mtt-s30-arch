# 第七轮准备：Wayland EGL 兼容、KWin 着色器及共享内存导入

**后续结果（2026-11-03）：本候选已在第七轮执行，客户端失败在 DRI screen 创建；新的 lookup-v1 修复及 7.2.14 构建见 [第七轮结果与第八轮准备](runtime-findings-20261103-094436.md)。本页保留当时准备记录，旧内核测试命令不用于当前直接重试。**

2026-10-31。**修复候选已构建并通过本地验证，可安排下一轮受控实机测试；尚未在 S30 上验证本轮窗口显示。** 第六轮的失败记录保持不变，不能把本轮软件结果当成硬件通过。

## 本轮修改

1. **原生 Wayland 客户端使用 ABI 匹配的 EGL 库。** 从原厂 `mtgpu_dri.so` 的 `DRI_Mesa` 扩展读出内部版本 `23.2.1-1ubuntu3.1~22.04.3`，选用 Ubuntu 同版本的 `libEGL_mesa` 和 `libglapi`。它支持新版 dma-buf 设备反馈，同时保留与厂商 DRI 匹配的内部接口；没有篡改版本字符串或关闭 ABI 检查。厂商 DRI/GLES 实现仍来自原始 3.1.0 包。合成器和 GBM 测试继续用原厂 EGL，只有原生 Wayland 客户端切换库。
2. **修复并重建 KWin 6.8.2。** 将模糊下采样着色器的五处 `texture2D` 改为 `texture`，与 KWin 的 GLSL ES 预处理和上采样实现一致。加入明确构建标记及 dma-buf 导入失败的尺寸、格式、modifier、plane、pitch/offset 诊断。完整补丁：[kwin-6.8.2-s30-test.patch](../patches/kwin-6.8.2-s30-test.patch)。
3. **普通共享内存窗口使用纹理上传。** 私有 KWin 设置 `KWIN_DISABLE_UDMABUF_IMPORT=1`，关闭将 `wl_shm` 包装为 udmabuf 后再导入的优化，保留真正的 GPU dma-buf 导入。另修正原条件，使显式关闭设置在缺少 EGL DRM 设备信息时也生效。第六轮 `EGL_BAD_PARAMETER` 的原日志没有图像来源，因此这是待实机核验的兼容处理，不能提前宣布该错误已彻底解决。
4. **强化实际运行组件的核验。** root 测试必须确认 KWin 的可执行文件和 `libkwin` 均来自本轮私有目录，日志含构建标记；客户端必须报告 `Mesa Project` EGL、加载本轮私有 EGL，并仍然以 MTT S30 渲染。文件/库校验失败或依赖缺失时，不启动监督服务。

KWin、EGL、glapi 和测试程序均暂存到 root 测试目录。系统 `/usr` 下的库和 KWin 保持原样，用户桌面配置不被读取或覆盖。本轮只运行独立 KWin 和测试窗口，不启动完整 Plasma 或 Xwayland。

## 制品、来源与验证

- Profile：`kwin-wayland-v2`。
- 制品目录：`builds/desktop-userland-fix1-v2-20261031`，包含六个固定文件。
- Manifest SHA256：`4a2f2c694807c91b2d467a41fac968296e3419d61c1f65682a39a339ea9fddcc`。
- 内核模块仍为 `db8e4393ec50e0e2542dafdb7277240627406b847dc19d0427444712249143bb`，未修改或重建。
- KWin 源码来自 KDE 6.8.2 官方发布包，SHA256 与官方校验文件一致；构建协议包的 Arch 签名验证通过。
- EGL/glapi 来自 [Ubuntu 2025-05-16 快照](https://snapshot.ubuntu.com/ubuntu/20250516T000000Z/dists/jammy-updates/InRelease)。已验证 Ubuntu Archive 2018 签名、Packages 索引 SHA256 和两个 deb 的包 SHA256；仅解包，没有执行安装脚本。
- 新 KWin 完整构建成功，配置与系统头文件相比仅关闭了配置模块构建。制品全部移除构建目录 RPATH/RUNPATH，依赖解析与再次复制校验通过。
- **45 项恢复/负载/桌面流程测试通过**，新增库损坏、目录符号链接、依赖缺失、Qt/KDecoration 版本漂移及依赖失败不启动 transient 服务的测试。
- 匹配 EGL 的软件离屏绘制 8 帧通过；最终私有 KWin 与私有 EGL 联合窗口测试 **60 帧、2,949,120 像素零差异、60 次呈现、零丢弃**。Python 独立核对最终图像通过；合成器受控退出，未强杀。
- 同一虚拟会话中的协议对照：原厂库没有请求新版反馈；新 EGL 发送 `get_default_feedback`。两个无 S30 设备的初始化对照均按预期失败，没有伪造设备成功。软件窗口结果也被硬件验收规则正确拒绝。

虚拟 KWin 同样会给出硬件呈现标志，故该标志不作为单独证据；实机仍需 S30 renderer、DRM 后端、物理输出、设备文件描述符、逐像素核对和私有组件路径全部满足。

完整证据与来源校验：[validation.json](validation/userland-fix1-20261031/validation.json)、[文件校验清单](validation/userland-fix1-20261031/evidence-sha256.json)。实现依据：[KWin EGL 导入](https://github.com/KDE/kwin/blob/v6.8.2/src/opengl/egldisplay.cpp)、[着色器预处理](https://github.com/KDE/kwin/blob/v6.8.2/src/opengl/glshader.cpp)。

## 启动下一轮

保存所有工作后，在自己的终端执行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

仍使用同一个入口，但新摘要 profile 必须是 `kwin-wayland-v2`。脚本会新建当前启动基线与 EFI 备份，再审计默认启动项和 initramfs；不会复用第六轮目录。当前执行器没有免密 sudo，因此需要用户在终端输入密码。

顺序是已通过的初始化/Vulkan/H.264、原厂 EGL/GBM、私有 KWin 和兼容 EGL 窗口。任何阶段失败即停止后续 GPU 测试，并保留日志。加载前的版本检查固定 KWin 6.8.2-1、Mesa 1:26.2.6-1、Qt Base/Declarative 6.12.0-3、KDecoration 6.8.2-1；再次系统升级时应先重新审阅。

## 失败后的启动保障

沿用已实测恢复的机制：**不安装模块、不写自动加载配置、不改内核/initramfs/启动项、不替换系统图形库；测试期间 ESP 只读。** 所有新组件只被本次 transient 服务显式引用，重启后原启动流程和系统桌面继续生效，不会开机重试失败驱动。

watchdog 仍先校准倒计时和喂狗，再启动测试；独立监督进程约 180 秒请求重启，另有 210 秒备用定时器。KWin 会话上限 75 秒，内部客户端上限 20 秒。硬件 watchdog 设置 60 秒；正常关机时 systemd 可能接管并使用既有 10 分钟超时。**硬件到期复位没有独立验证，不能保证所有硬件挂死都自动恢复。**

若黑屏，先等待计划重启；控制台仍有响应时可按 Ctrl+Alt+F3 登录并执行 `sudo systemctl reboot`。超过约 10 分钟仍无进展且控制台无响应时，需要本机强制关机后再开机，选择原 EndeavourOS/Arch 7.2.11 启动项。不要重复启动测试，先检查日志。完整恢复说明见 [recovery/README.md](recovery/README.md)。

重启后读取新的 `/var/tmp/mtt-s30-test-<时间戳>.json`；必要时再用 `collect-results.py` 导出对应新目录。通过条件仍为 `desktop_checks_passed` 加 EFI 恢复核验；本轮没有执行最终扫描输出截图、完整 Plasma/Xwayland、长期运行、休眠恢复或 LTS 实测。

## 重建

在项目根目录，以普通账户运行；输出必须是新目录：

```bash
python3 maintenance/desktop/build-userland.py --work work/userland-fix-20261031 --output builds/my-userland-rebuild --jobs 8
```

脚本固定源包 SHA256、应用补丁、在项目内构建 KWin、仅解包匹配 EGL/glapi、构建测试工具并生成文件清单。不会运行安装目标、停止桌面或访问 GPU。新 manifest 只有在审阅和自检后才能更新到恢复入口。

软件对照使用独立的 Ubuntu swrast/LLVM 测试依赖；它们未包含在 root 硬件制品中。复现命令见 `maintenance/desktop/validate-userland.py --help`，测试结果不能作为 S30 硬件通过。
