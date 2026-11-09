# MTT S30 第二次测试：实际加载成功，兼容性验证未通过

2026-10-29 22:51 启动测试，22:52:12–14 加载初始化，22:54:40 开始计划重启。当前运行 7.2.11-arch1-1，KDE 已恢复，mtgpu 未安装、未自动加载。

## 已证实的进展

- `insmod` 返回 0（1.467 秒）；PCI `0000:04:00.0` 绑定 `mtgpu`，创建 `renderD128`。
- 日志记录 DRM 注册、HDMI 1920×1080 @ 60 Hz 模式设置、像素时钟锁定与 `mtgpudrmfb` 接管控制台。这是驱动日志证据，不是用户目视画面验证，也不等于图形加速验证。
- 内核故障检查中止了后续管理工具、Vulkan 和 VA-API 调用。它们全部未测；KDE 硬件加速和稳定性仍未测。
- 管理员导出的恢复核验为 True：11 个 ESP 文件中 10 个相同，只有 `loader/random-seed` 正常轮换，无增删。原默认启动项及内核/initrd 核验通过；未证明 watchdog 超时复位。

## 本轮定位与补丁

| 问题 | 原因与证据 | 修订状态 |
| --- | --- | --- |
| `workqueue.c:5851 __alloc_workqueue` WARNING | IPC 的 `os_alloc_workqueue` 没指定 `WQ_PERCPU` 或 `WQ_UNBOUND`；7.2.11 发出警告后补 PERCPU。原闭源调用点为 `mtgpu_ipc_init+0x44`。 | conftest 编译探测枚举；兼容层显式保留旧 PERCPU 默认，不改已有 UNBOUND 选择。覆盖 common/PVR wrapper 与 fence 路径。 |
| `memtype.c:721 memtype_reserve_io` WARNING | `mtgpu_mtrr_setup` 预留整个显存 BAR 时，BOOTFB 仍拥有其中一段；固件 framebuffer 移交发生得太晚。 | PCI probe 包装入口先调用 `aperture_remove_conflicting_pci_devices`，成功后才进入闭源 probe；移交失败直接返回错误。适用于此次两个现代内核，旧分支保留原路径。 |

两处是候选修复，尚未加载验证。没有更改闭源二进制，也没有屏蔽 WARN 或关闭内核缓解措施。
Linux 文档要求在 probe 起始处完成 framebuffer 移交：[7.2 aperture 文档](https://docs.kernel.org/7.2/driver-api/aperture.html)。工作队列警告与本地保存的 [Linux v7.2.11 源码](https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux/+/refs/tags/v7.2.11/kernel/workqueue.c) 对应。

## 仍未解决，不能忽略的日志

1. `DISPC-2: dispc_stop() wait dispc disable done timed out`。之后模式设置成功，不足以证明这个超时无害。源码在 DRM 尚未完全初始化时先调用闭源 deinit，再开中断；注释明确说明过早开中断可能 Oops，因此没有贸然颠倒这两步。
2. VPU 映射 `0xea108000–0xea116fff` 跨过 `dispc-regs 0xea116000–0xea116fff`，内核输出 `resource sanity check` / `mapping multiple BARs`。闭源 SUDI 配置确实给出 base 0x108000、size 0xf000、三个 0x4000 core 和 top offset 0xd000；没有寄存器完整访问范围依据，不能直接缩短映射来消除日志。

新 runner 将这两类信息也作为停止后续 GPU 调用的条件；新增加载后的 `/proc/iomem` 与 PCI resource 快照，用于核对资源归属。下一轮可能仍在初始化检查停止，届时先比较这次两处修复效果及剩余问题，不能宣称所有硬件验证通过。

## 已完成验证

- 从固定哈希的官方 deb 干净构建 7.2.11-arch1-1、6.18.58-1-lts：均成功，modpost/链接成功、S30 alias 和 vermagic 正确。
- 对最终两个模块反汇编确认：先移交 aperture 再进入 vendor probe，两个 workqueue wrapper 都补了 0x100 PERCPU 位。
- 8 项真实兼容层代码回归（ASan/UBSan）通过，23 项恢复脚本测试通过；包含移交失败禁止进入 vendor probe、旧模块只允许历史审计、新增资源冲突禁止进入 GPU 用户态检查。
- 每个构建仍有 5486 条厂商 blob 的 objtool 警告。LTS 仅有项目内头文件和构建产物，未安装、未启动测试。

修订模块位于 `/home/bull/Documents/mtt-s30-arch/builds/runtime-fix-7.2.11-20261029/source/mtgpu.ko`；SHA256：`824b81aa1a2cae0714bf670b78cf0a29ceaac87f6ac395281a3acb44fb530a0c`。
新的预检和 runner 已固定选择此模块。旧 root 测试目录保持原样，仅允许收集历史证据，不能用旧模块开始新测试。

## 下一次受控验证

保存工作后，在自己的终端执行下列命令；会退出 KDE 并计划重启：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start
```

新建并核验 EFI 备份，确认桌面退出后临时加载修订模块。仍不安装开机驱动、不修改内核/initramfs/启动参数。每轮约 3 分钟请求正常重启，但不能保证所有硬挂死都能自动恢复。
执行器没有免密 sudo，必须由你在自己的终端输入密码。重启后读取新时间戳的测试结果。

完整结构化证据见同目录 `mtt-s30-second-run-analysis.json`；补丁和修订脚本见 `mtt-s30-runtime-fix-20261029.tar.gz`。本次旧原始日志位于 `/var/tmp/mtt-s30-results-20261029-225127`。
