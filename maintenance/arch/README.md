# Arch Linux MTT S30 驱动软件包规范与维护指南

本项目为摩尔线程（Moore Threads）MTT S30 独立显卡在 Arch Linux（内核 7.x+ 与 KDE Plasma 6.x Wayland）上构建了符合 Arch Packaging Standards 的标准软件包套件：

1. **`mtgpu-s30-dkms`**：内核模块源码、固件与 DKMS 自动编译配置。
2. **`mtgpu-s30-userland`**：OpenGL、Vulkan、VA-API 硬件解码、MUSA 计算运行时、Wayland 兼容层与桌面环境配置。

---

## 一、软件包架构

```text
mtt-s30-arch/
└── maintenance/arch/
    ├── mtgpu-s30-dkms/               # 内核层
    │   ├── PKGBUILD                  # 内核配方
    │   ├── .SRCINFO                  # AUR 元数据
    │   ├── linux-modern.patch        # 现代内核 (7.x) DRM 适配补丁
    │   ├── prepare.py                # 内核树补丁生成脚本
    │   └── mtgpu-s30-dkms-*.pkg.tar.zst
    │
    └── mtgpu-s30-userland/           # 用户态层
        ├── PKGBUILD                  # 用户态配方
        ├── .SRCINFO                  # AUR 元数据
        ├── repair-mtgpu-dri.py       # Wayland 析构函数 double-free 补丁脚本
        ├── libEGL_mesa.so.0          # Mesa 23.2.1 EGL Wayland 兼容协议桥
        ├── libglapi.so.0             # 协议桥配对 GLAPI
        ├── 50_mtt_mesa.json          # EGL ICD 描述文件
        ├── 10-mtt-s30.conf           # 桌面环境变量提示 (GBM/KWin)
        ├── 70-mtgpu.rules            # /dev/musa* 权限 udev 规则
        └── mtgpu-s30-userland-*.pkg.tar.zst
```

---

## 二、通用驱动发布流程（Arch / AUR 发布规范）

在 Arch Linux 生态中，维护专有/半开源显卡驱动遵循以下通用流程：

### 1. 拆包原则（DKMS 与 Userland 分离）
- **DKMS 包（内核层）**：只包含必要内核模块源码和固件，依赖 `dkms`。当系统升级内核时，DKMS 会自动触发 `make` 重建驱动，无需手动重新打包。
- **Userland 包（用户态层）**：包含所有的 `.so` 动态库、DRI 驱动、Vulkan ICD、VA-API 驱动、MUSA 计算库和桌面环境配置。独立于内核版本。

### 2. AUR 规则与源码获取
- **禁止在 AUR Git 仓库提交大型二进制文件**：AUR 仓库仅用于托管文本配方（`PKGBUILD`、`.SRCINFO`、补丁 `.patch`、小脚本）。
- **专有大包的引用方式**：上游固件与闭源核心来自摩尔线程官方驱动 deb 包（`musa_3.1.0-pc_x86.deb`）。在 PKGBUILD 中将其声明在 `source=(...)` 和 `noextract=(...)` 中，并严格绑定 `sha256sums`。用户在通过 `makepkg` 或 AUR helper 构建时，只需将下载的 deb 放在同目录即可。

### 3. 本地打包与校验命令
```bash
# 构建内核包
cd maintenance/arch/mtgpu-s30-dkms
makepkg -s -f

# 构建用户态包
cd maintenance/arch/mtgpu-s30-userland
makepkg -s -f
```

### 4. 命名空间与系统冲突检验
已通过 `pacman -Qo` 对软件包中所有 130+ 个安装路径进行扫描：
- **与官方 `mesa` 包完全隔离**：`libEGL_mesa.so.0` 安装于 `/usr/lib/mthreads/egl/` 私有目录，不覆盖官方系统的 `/usr/lib/libEGL_mesa.so.0`。
- **动态库隔离**：所有动态库具有唯一的 SONAME（`libdrm_mtgpu.so`, `libGLX_mtgpu.so`, `libVK_MT.so` 等）。
- **零文件冲突（Zero Conflicts）**：可与 Arch Linux 官方图形栈安全共存。

---

## 三、长期维护与演进规划

### 1. 内核升级跟踪（Kernel ABI Maintenance）
- 随着 Arch Linux 内核滚动更新（如 Linux 7.3+），内核 DRM 子系统函数签名可能会有变动。
- 维护方式：只需维护 `linux-modern.patch`，当遇到编译报错时定位对应头文件变更并更新补丁，递增 `pkgrel` 重新发布。

### 2. 硬件传感器与 KDE System Monitor 原生集成（hwmon 路线）
- **现状**：官方 `mtgpu` 内核驱动未注册标准 Linux `hwmon`（硬件监控）接口，仅通过 `/dev/musa*` 私有 ioctl 给 `mthreads-gmi` 提供数据。KDE 的 `ksystemstats` 无法在 `/sys/class/hwmon/` 找到显卡传感器。
- **演进方案**：在 `mtgpu_drv.c` / `mtgpu_device.c` 中添加标准的 Linux `hwmon_device_register_with_info()` 驱动代码，将温度、风扇、显存使用量映射到 `/sys/class/hwmon/hwmonX/temp1_input` 等标准 sysfs 节点。届时 KDE System Monitor、`sensors`、`btop` 将无需任何辅助守护进程即可自动识别 MTT S30。
