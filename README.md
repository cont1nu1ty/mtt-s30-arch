# Moore Threads MTT S30 Arch Linux 驱动与桌面适配套件

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-Kernel_7.x-blue.svg?logo=archlinux)](https://archlinux.org/)
[![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6.8_Wayland-31A8FF.svg?logo=kde)](https://kde.org/)
[![License](https://img.shields.io/badge/License-Dual_MIT%2FGPL-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/cont1nu1ty/mtt-s30-arch)](https://github.com/cont1nu1ty/mtt-s30-arch/releases)

本项目为摩尔线程（Moore Threads）**MTT S30 [1ed5:0102]** 独立显卡在 **Arch Linux（Linux 内核 7.x+ 与 KDE Plasma 6.x Wayland）** 上的完整社区适配套件与标准软件包。

通过自动修补与协议适配桥，本项目彻底解决了上游驱动在现代 Arch Linux 上的内核编译失败、Wayland 双重释放崩溃、Plasma 桌面分发槽 NULL 异常等关键兼容性难题，让 MTT S30 能够作为全功能桌面显卡稳定运行于 Arch Linux 之上。

---

## 🌟 核心特性与实机验证能力

所有功能均在真实硬件（海光 C86-3G 平台 + MTT S30 HDMI-A-1 1080p 60Hz，Arch Linux 64位系统）上完成严苛的逐帧无错误验证：

- 🖥️ **KDE Plasma 6.8.2 Wayland 原生桌面**：
  - `plasmashell` 原生运行于 S30 Desktop OpenGL 4.3 渲染器；
  - 桌面文件夹与底部 Dock 面板全量通过硬件 DMA-BUF 零拷贝合成（300+ 硬件 presentation 帧零错误）；
  - 动态面板高度修改、状态保存与 Teardown 退出完全通过。
- ⚡ **Wayland GLES 与 Qt Quick 硬件加速**：
  - 原生 Wayland 窗口及 Qt Quick 现代应用（GLES 3.x）硬件渲染与交换退出 0 错误。
- 🎮 **Xwayland GLX 无缝兼容**：
  - X11 图形程序通过 DRI3 `/dev/dri/renderD128` 直接零拷贝硬件加速（OpenGL 3.3），无需 glamor 软件回退。
- 🎬 **硬件视频编解码（VA-API）**：
  - MTT VPU 硬件加速流畅解码 1080p60 H.264 视频流（逐帧与 CPU 参照实现 100% 像素级一致）。
- 🌋 **Vulkan 1.0 支持**：
  - 通过 `libVK_MT.so` 导出标准 Vulkan ICD，支持标准 Vulkan 图形与计算管线。
- 🧮 **MUSA 计算与 AI 运行时**：
  - 完整保留 `mthreads-gmi` 状态监控工具与 MUSA Tensor 计算 SDK（`/usr/include/musa`、`libmusa.so`、`libmusart.so`）。

---

## 📦 软件包结构

项目按照 Arch Linux 官方打包规范拆分为两个独立的软件包：

1. **`mtgpu-s30-dkms`（内核与固件层）**
   - 包含 Linux 7.x 现代内核 DRM/VFS 适配补丁（`linux-modern.patch`）与全部 26 个硬件固件。
   - 当系统滚动更新内核时，通过 DKMS 自动触发编译，无需手动重建。
2. **`mtgpu-s30-userland`（用户态图形与计算层）**
   - 提供经过双重释放修复的 DRI 驱动、Vulkan ICD、VA-API 驱动、MUSA 库与私有 Mesa EGL 兼容桥。
   - 经过 `pacman -Qo` 全量扫描，与 Arch 官方系统包（`mesa`、`libglvnd` 等）**零文件冲突**。

---

## 🚀 快速安装

### 方案 A：一键安装预编译包（推荐）

直接使用 `pacman` 从 GitHub Releases 安装构建好的标准 `.pkg.tar.zst` 二进制包：

```bash
# 1. 确保安装了 dkms 与内核头文件
sudo pacman -S --needed dkms linux-headers

# 2. 从 GitHub Releases 一键下载并安装
sudo pacman -U \
  https://github.com/cont1nu1ty/mtt-s30-arch/releases/download/v3.1.0/mtgpu-s30-dkms-3.1.0-2-x86_64.pkg.tar.zst \
  https://github.com/cont1nu1ty/mtt-s30-arch/releases/download/v3.1.0/mtgpu-s30-userland-3.1.0-1-x86_64.pkg.tar.zst
```

---

### 方案 B：源码自动构建（AUR / makepkg）

本仓库的 `PKGBUILD` 已经配置了从 GitHub Releases 自动静默下载官方 deb 资产，**完全跳过官网的短信验证码**：

```bash
# 1. 克隆本仓库
git clone https://github.com/cont1nu1ty/mtt-s30-arch.git
cd mtt-s30-arch

# 2. 构建并安装内核 DKMS 包
cd maintenance/arch/mtgpu-s30-dkms
makepkg -si

# 3. 构建并安装用户态驱动包
cd ../mtgpu-s30-userland
makepkg -si
```

---

## 🛠️ 关键技术修复与架构原理

1. **WaylandSwapChain 析构函数 Double-Free 硬件修补**：
   - 官方闭源 `mtgpu_dri.so` 在 Wayland 窗口销毁时会重复调用一次基类析构，触发 `SIGSEGV`。
   - 本项目通过 `repair-mtgpu-dri.py` 在 `prepare()` 阶段将 `0x5A51A0` 和 `0x5875E0` 处的冗余 call 指令精准替换为 5 字节 NOP（`0f1f440000`），彻底消除窗口关闭时的崩溃。
2. **Wayland EGL 现代协议与 ABI 桥（Mesa 23.2.1）**：
   - 解决官方 EGL 缺少现代 Wayland DMA-BUF feedback 以及 loaderPrivate 偏移不匹配导致被识别为 X11 后端的问题。
   - 在私有目录 `/usr/lib/mthreads/egl/` 中提供兼容桥，保持系统官方 `mesa` 不受任何污染。
3. **Plasma 6.8.2 OpenGL 分发槽 NULL 异常规避**：
   - 解决 Qt 6 / Plasma 调用 `glGetGraphicsResetStatus` 时因厂商 DRI 虚表 slot 841/973 未填充而发生段错误的问题。

---

## 📄 许可证与合规声明

- 本仓库中由社区维护的补丁、脚本与文档遵循 **MIT** 或 **GPLv2** 许可证。
- 驱动中的预编译二进制核心与硬件固件版权归 **摩尔线程智能科技（北京）有限责任公司** 所有，保留其原始 `License.txt` 许可条款。
- 本项目为非商业性质的 Arch Linux 社区硬件兼容性适配套件。
