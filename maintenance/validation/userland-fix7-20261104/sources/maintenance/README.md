# 摩尔线程 MTT S30 / Arch 维护项目

更新：2026-11-04。**最新 v7 的基础渲染/硬解及 EFI 恢复通过，但当前格式查询仍保留 XB24，KWin 导入失败，客户端未执行。** v8 已将查询集合限制到固定厂商版本的实际导入表，35 项源码/最终库回归（含旧 v7 必须失败的真实反例）、64 项流程测试及 60 帧软件窗口验证通过，可安排受控实测。见 [最新结果与 v8 准备](runtime-findings-20261104-200750.md)。v8 设备效果及沿用的 v6 display 桥接仍待实测；驱动未持久安装，每轮新建 EFI 备份。

在 7.2.11-arch1-1 上，新模块 `db8e4393…49143bb` 已实际加载；原工作队列告警、DISPC 关闭超时和 VPU 映射冲突消失。管理工具、Vulkan 和 VA-API 均返回 0 并识别 S30。截至第六轮，EFI 11 个文件中仅随机种子轮换，原系统和 KDE 已恢复，驱动未持久安装。

第五轮实际绘制 8 帧、98,304 个像素零差异；48 帧 H.264 全部硬解，与 CPU 参考逐字节一致。导出后再次复核图像和完整视频数据通过；加载至关机的新增内核日志未出现原三项故障。详见 [第五轮负载结果与边界](runtime-findings-20261030-084900.md)、[第四轮枚举记录](runtime-findings-20261029-235643.md) 和 [源码修复及构建验证](runtime-fix3-20261029.md)。其他视频格式/编码、计算、加速 KDE 和持续稳定性仍未验证；LTS 仅构建通过；闭源 objtool 告警仍存在。

维护目录 `/home/bull/Documents/mtt-s30-arch`。14 项源码回归、64 项恢复/负载/桌面流程测试通过；所有旧日志与构建保留。

2026-10-31 已执行隔离 KWin/Wayland 测试：KWin 使用 S30 驱动 HDMI 输出，但客户端 EGL 失败，journal 还有特效着色器和 EGLImage 导入错误。新候选使用内部 ABI 匹配的 EGL 设备反馈路径、已重建的着色器修复和私有共享内存兼容设置，当时 profile 为 `kwin-wayland-v2`。之后已正常启动 7.2.14 并测试到 v7；最新状态以本文顶部为准，完整 Plasma/Xwayland 未测。

用户系统升级后已重新审阅 KWin 6.8.2-1 / Mesa 1:26.2.6-1。旧版本保护拦截的 `20261031-190526` 没有退出桌面或加载驱动；随后 `20261031-191508` 实测暴露上述兼容问题。升级前的软件验证边界见 [升级复核记录](desktop-upgrade-review-20261031.md)。

基线是官网桌面驱动 `musa_3.1.0-pc_x86.deb`，不是 MUSA SDK 5.2.0。
官网 3.1.0 发行说明列出 S50/X300、海光和内核 4.9–6.8；源码仍含 S30 PCI ID `1ed5:0102`。
因此本项目为 S30 的实验适配，不能称为厂商认证支持。

## 本次结果

| 内核 | 来源 | 构建/链接/符号检查 | 实际加载与图形测试 |
| --- | --- | --- | --- |
| 7.2.11-arch1-1 | 本机安装的 headers | 通过，含修订版干净重建 | 初始化、Vulkan / H.264 / EGL-GBM 及恢复通过；KWin 启动，但原生 Wayland 客户端失败 |
| 7.2.14-arch1-1 | 升级后本机 headers | 干净构建、链接、832 个外部符号核验通过 | 模块、Vulkan/H.264/EGL-GBM 通过；v7 格式刷新仍保留 XB24，KWin 导入失败，客户端未执行；数据及 EFI 恢复复核通过 |
| 6.18.58-1-lts | Arch Archive headers，pacman-key 验证 Christian Hesse 签名通过 | 通过，独立源码目录 | 未执行 |

只证明表中具体版本的构建结果，不代表整个 6.18–7.2 区间或后续版本都支持。
LTS 头文件只解包到本项目，**没有安装或切换系统内核**。

产物与证据位于上一级目录：

- `builds/7.2.11-clean/source/mtgpu.ko`、`build.log`、`result.json`
- `builds/7.2.11-workflow/`：build.py 一键流程的端到端成功记录
- `builds/6.18.58-v2/source/mtgpu.ko`、`build.log`、`result.json`
- `official/musa_3.1.0-pc_x86.deb`：原始安装包，SHA256 为 `04c286ba452fe0cfbea2c47465f0c48b0659c09b896f05f363feba680dd8efda`。
- `official/driver-3.1.0/`：只解包、未执行安装脚本的原始文件。
- `work/mtgpu-3.1.0/`：当前维护源码；厂商二进制核心未修改。
- `patches/linux-modern.patch`：包含上游社区补丁和本次兼容层变更的完整补丁。

14 项回归测试通过（包含启动阶段 MMIO/IRQ/映射边界；用真实函数编译，ASan/UBSan 检查）：新增 workqueue 类型/旧内核兼容、全部直接分配调用覆盖、PVR 初始化分配失败、PCI 移交顺序/失败传播；既有项目为固定宽度字符串复制；四参数 mkdir 生命周期；五参数 mkdir 生命周期；IOMMU 总线选择、歧义拒绝和引用释放。这些 Fake API 测试不替代实际内核测试。
64 位用户态 ELF 的直接依赖在本机系统/厂商包内均能找到；这不是驱动加载验证。
模块声明的固件在原包中均存在；S30 PCI alias 与目标内核 vermagic 已核对。

## 修改内容与限制

- 修复内核接口探测的 GNU11、MS 扩展、compiler headers；加入头文件编译自检，防止编译器环境坏掉时把所有 API 误判为缺失。
- 移植 dixyes 的可复用 6.10–6.14 补丁（来源在 `../patches/upstream/`）。没有伪装 Ubuntu；反汇编中的该拒绝路径比较的是设备 0x0201，不是本机 S30 0x0102。这只是对该具体检查路径的静态核对。
- 兼容 mempool 改名、timer/hrtimer、PCI BAR resize、DRM atomic transaction 改名、异步 cursor 回调、connector const 参数、PFN、dma_fence 与 fence array 接口。
- 以每设备互斥锁替代被删除的 DRM struct_mutex。该字段追加到私有结构尾部，不移动原有字段；二进制调用点为 GEM dma-buf mmap。并发行为仍须运行验证。
- VFS adapter 在 wrapper 自己分配的 opaque path 中保存 mkdir 的返回 dentry/error，遵守新内核替换/消费 dentry 的所有权规则，避免重复 dput/unlock。四参数/五参数版本分别探测。
- 厂商 ABI 只给 IOMMU 总线、不提供目标设备；兼容层只在总线上的 domain owner 一致时选择设备分配 paging domain，发现多种 owner 则明确失败。多 IOMMU/热插拔拓扑仍未验证。
- `strncpy` wrapper 保留截断不补终止符、短串补零、返回原目标指针的语义；顺带修复原始 executable VMA wrapper 对空 vm_file 的错误判定。
- Kbuild 正确记录厂商预编译对象的 `.cmd`，使现代 modpost 能完成；没有跳过 modpost、没有放宽编译错误。

**闭源核心限制仍在：** 两个构建各报告 5486 条 objtool 警告，其中 5051 条涉及裸返回指令、42 条涉及 !ENDBR 数据重定位；还有间接跳转等警告。没有隐藏警告或修改二进制来让检查看起来通过。
本机海光 CPU 未声明 IBT，因此内核 CONFIG_X86_KERNEL_IBT=y 不能直接解释为本机硬件强制执行 IBT；但闭源核心与当前返回跳板/投机执行缓解策略的一致性未得到保证。其他启用 IBT 的 CPU 更不能直接复用本模块。
编译成功不证明 ABI、内存所有权、锁、DMA、GPU firmware、桌面合成和恢复路径都正确。

## 重建

需要已有 Python 3、libarchive/bsdtar、patch、make、编译器和目标内核 headers。脚本不安装依赖。
所有输出目录必须是新目录；不会覆盖已有工作。

```bash
python3 maintenance/build.py \
  --deb official/musa_3.1.0-pc_x86.deb \
  --output builds/my-7.2-check \
  --kernel-build /lib/modules/7.2.11-arch1-1/build \
  --jobs 4
```

从本项目根目录执行。脚本校验包哈希、重新解包源码、以零 fuzz 应用补丁、构建并写 result.json。
哈希固定的是本次审阅过的具体安装包；上游同版本包发生变化时也必须重新审阅，不能直接改哈希绕过检查。
补丁前先解开厂商自解压 conftest 为文本，该步骤已内置于 prepare.py。

```bash
MTGPU_SOURCE="$PWD/builds/my-7.2-check/source" python3 maintenance/tests/test_wrappers.py
```

修改 `work/mtgpu-3.1.0` 后，用 `python3 maintenance/export_patch.py` 重新导出补丁，再从原包干净重建。
同步更新 PKGBUILD 的补丁哈希；不要把 work 中的 .o/.ko 或生成 conftest.h 打入源补丁。

## Arch 打包

`arch/PKGBUILD` 是**实验内核包草案**；makepkg --verifysource 的三项哈希校验通过，.SRCINFO 生成通过。尚未构建/安装完整包、未作为完成的发布包验证。
把 PKGBUILD、官方 deb、prepare.py 和 linux-modern.patch 放在一个独立打包目录，用 `makepkg --verifysource` 验证，再按正常 Arch 打包流程构建。
包名为 mtgpu-s30-dkms，依赖 dkms；厂商 Debian initramfs/post-install hooks 不会执行。
该草案只处理内核源码，**不包含固件和用户态部署**，安装它不能被视作显卡已可用。
DKMS AUTOINSTALL 只代表尝试重建，不代表新内核已经验证。正式使用前须配置已验证内核的回退启动项。
当前不上传 AUR、GitHub，不发布厂商二进制；分发授权应另外核对。

## 下一阶段：受控加载

详见 [runtime-plan.md](runtime-plan.md)。这是会影响当前显示会话的测试，需要用户先保存工作并安排窗口。
不得在现有 KDE 会话中直接加载；受控测试使用临时固件路径，重启后恢复；没有持久安装驱动或修改 initramfs、启动项和图形配置。
