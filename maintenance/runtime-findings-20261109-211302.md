# 2026-11-09：v13 全面通过！KDE Plasma 桌面外壳与 Xwayland GLX 实机验收成功

2026 年 11 月 9 日 21:13 的 `20261109-211302` 在内核 `7.2.14-arch1-1` 上完成了 `kwin-plasma-xwayland-v13` 实机测试。**全部验收项通过（Probe Exit: 0），KDE Plasma 6.8.2 桌面外壳、面板、活动管理与 Xwayland GLX 直接 3D 加速在摩尔线程 MTT S30 显卡上全链路通过硬件实测，启动配置与 EFI 恢复核验通过（Recovery verification: True），未产生任何崩溃记录。** [本轮独立核验](validation/runtime-20261109-211302/analysis.json) · [输出复核](validation/runtime-20261109-170542/output-verification.json)

## 1. 本轮硬件验收结果

本轮采用 12 文件制品包 `builds/desktop-plasma-v13-20261109`（清单 SHA256: `7d9e8aa3574ffecd34ae810baefb039411763d77445cd5017623e5b02b47cf40`），包含修复了 `glGetGraphicsResetStatus` 空分发槽的私有 Mesa 兼容层 `libEGL_mesa.so.0`。

| 测试路径 | 运行时检查 | 导出后独立复核 | 结论 |
| --- | --- | --- | --- |
| **Vulkan** | 8 帧、98,304 像素零差异 | 末帧逐字节匹配 | **通过** |
| **H.264 VA-API** | 48 帧全部硬件解码 | 4,423,680 字节与 CPU 重新解码逐字节一致 | **通过** |
| **EGL/GBM** | 8 帧、393,216 像素零差异 | 末帧逐字节匹配 | **通过** |
| **原生 Wayland GLES** | 5 轮各 60 帧，共 300 次硬件呈现、14,745,600 像素 | 请求/反馈完整配对，全部标志 7，跨轮时间戳递增 | **通过** |
| **Qt Quick GLES** | 12 帧、589,824 像素，14 次交换 | 末帧与公式逐字节匹配，PNG 解码一致，应用清理通过 | **通过** |
| **KDE Plasma 桌面** | 文件夹桌面与默认面板实际存在；使用 S30 桌面 OpenGL 4.3 渲染；桌面图层提交 33 帧 DMA-BUF，面板提交 41 帧 DMA-BUF | 面板高度动态交互调整并恢复通过（前后 JSON 逐字节一致）；`plasmashell` 正常退出（Exit 0） | **通过** |
| **Xwayland 服务** | `/usr/bin/Xwayland` 独占 `:100`；加载厂商 EGL/DRI 库；持有 S30 `renderD128` | 无 glamor 软件回退，服务正常受控退出 | **通过** |
| **X11 3D 加速 (GLX)** | 直接 GLX、桌面 OpenGL 3.3（MTT S30）；12 帧、589,824 像素零差异 | DRI3 返回实际 S30 render node；12 次交换后完整销毁并退出 0 | **通过** |
| **退出与系统恢复** | KWin 按请求以信号 15 退出，无 forced kill；计划重启 | EFI 10 个文件一致仅 random-seed 正常轮换；无任何崩溃 core | **通过** |

## 2. 核心证据解析

1. **Plasma 桌面与面板硬件渲染**：
   - `plasmashell` PID 40412 成功建立双桌面 OpenGL 上下文（`GL_VENDOR: Moore Threads`, `GL_RENDERER: MTT S30`, `GL_VERSION: 4.3 build 20250122_master-227-gdf7bc68e`）。
   - 文件夹桌面图层（Surface 53）共完成 33 次 DMA-BUF 缓冲提交；面板图层（Surface 85）共完成 41 次缓冲提交。
   - 通过 D-Bus 脚本动态修改面板高度并恢复，前后配置（`plasma-before.json` 与 `plasma-after.json`）完全吻合，证明面板布局在 S30 加速下具备完整的动态响应能力。
   - 上一轮引发 SIGSEGV 的 `QEGLPlatformContext::checkGraphicsReset()` 调用被 v13 补丁的安全桩函数平稳吸收，`plasmashell` 正常运行至测试结束，收到 SIGTERM 后退出码为 0。

2. **Xwayland GLX DRI3 零拷贝直通**：
   - KWin 成功拉起 `/usr/bin/Xwayland` PID 40514，并配置专用显示 `:100` 与 xauthority 认证。
   - Xwayland 成功加载 `dri/mtgpu_dri.so` 与 `libEGL_mtgpu.so.0.0.0`，未出现任何 glamor 软件回退信息。
   - X11 测试客户端（`x11-client.log`）证实加载了系统与厂商混合的 `libGL.so.1`、`libGLdispatch.so.0`、`libGLX_mtgpu.so.0` 和 `mtgpu_dri.so`，DRI3 成功枚举 `/dev/dri/renderD128`（设备主/次号 226/128），12 帧渲染末帧与预期公式逐像素匹配。

3. **启动文件与安全回滚**：
   - 测试启动 ID：`4fd8b8ae-7e86-42bd-adea-ebea071a0e49`；当前重启启动 ID：`6090af90-47f4-44dd-b76f-8898cbe78e7e`。
   - EFI 分区 11 个文件中 10 个完全一致，仅 `loader/random-seed` 正常轮换。
   - 所有客户端（Wayland、Qt Quick、X11、Plasma、Xwayland）均未产生崩溃转储，`client_core` / `qt_client_core` / `x11_client_core` / `plasma_core` / `xwayland_core` 均为 `not_found`。

## 3. 下一步：Arch Linux 打包与维护规范

既然内核模块（7.2.14 接口兼容）、用户态 EGL 协议兼容桥、KWin 呈现、Plasma 桌面以及 Xwayland 加速链路已全数在真实硬件上验证闭环，我们现在可以正式开始准备交付阶段：

1. **整理内核模块 DKMS 包**：完善 `mtgpu-s30-dkms` 的 `PKGBUILD`，纳入已通过检验的全部 6.x/7.x 内核接口补丁。
2. **整理用户态运行时包**：打包经过 S30 兼容性修补的私有 Mesa EGL 库、Xwayland 规则配置以及必要的环境变量配置（不采用全局劫持系统库的破坏性方式，而是通过标准 Arch/systemd/Wayland 机制自动载入）。
3. **打包验证与 AUR 发布准备**：在本地干净环境中测试 `makepkg`，验证安装、升级与卸载干净度。
