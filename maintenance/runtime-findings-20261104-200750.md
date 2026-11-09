# 2026-11-04 20:07：v7 格式刷新执行，但仍保留不可导入的 XB24

本轮 `20261104-200750` / `kwin-wayland-v7` / Linux `7.2.14-arch1-1` **整体未通过，启动与 EFI 恢复核验通过**。不是客户端再次崩溃：验收在 KWin 启动阶段中止，原生 Wayland 客户端未执行，v6 display 桥接仍未经过设备窗口验证。

## 实测与恢复

- Vulkan 8 帧 / 98,304 像素、H.264 48 帧硬解、EGL/GBM 8 帧 / 393,216 像素通过；保存像素和完整视频数据独立复核一致。
- 新私有 KWin 确实执行当前上下文格式刷新：初始 22 项，经 modifier 查询收窄为 8 项，但仍包含 `XB24` 和 `AB30`。
- `1920×1080 XB24`、单平面、pitch 7680、offset 0、隐式 modifier 导入仍返回 `EGL_BAD_PARAMETER`。随后有匹配 HDMI 主输出尺寸的 `XR24` 正常无复制 DRM-layer 成功记录。日志顺序与源码符合逐格式失败后回退，但失败行没有 producer/attempt ID，不能把该归属说成直接采集的事实。
- 原错误检测保留，本轮严格判失败；客户端未启动、没有其退出码或崩溃文件。
- 加载至关机没有新增内核 BUG/WARNING/调用栈。计划重启后内核仍是 7.2.14，KDE active，mtgpu 未安装/未加载，临时测试服务/计时器及 watchdog inactive。
- EFI 11 文件中 10 个相同，仅 `loader/random-seed` 正常轮换；无新增/删除。

[本轮独立核验](validation/runtime-20261104-200750/analysis.json)。硬件 watchdog 倒计时/刷新/启停已核验，但没有主动验证超时复位；本轮正常重启不能证明所有内核挂死均能自动恢复。

## 对上一轮假设的修正

v7 的本地回归验证了查询结果正确收窄时的交集逻辑，却没有覆盖实际厂商次级 context 分支。EGL context 成为 current 不等于厂商 primary TLS context 已建立。因此，“current 后重新查询就会排除 XB24”的假设被本轮实机结果否定。

进一步检查官方 3.1.0 原始 ELF：EGL 查询 wrapper 每次直接调用 DRI format callback，没有缓存。厂商 bindContext 在 context 的 secondary 指针非空时直接调用次级 bind，不设置 primary TLS；格式列表继续由 musa 次级路径提供，而 modifier 查询使用另一张主表。

受系统调用限制的纯 CPU 原指令回放重现了：次级 bind 不写 primary TLS；查询 22 项经真实 modifier callback 得到与本轮完全一致的 8 项；显式构造 primary TLS 后才返回主 18 项，清除后又回到 22 项。没有执行 EGL 初始化、GPU 打开或真实 context 创建。

真正的 DMA-BUF 导入函数在设备导入之前无条件检查主 18 项表，其中既没有 XB24，也没有 AB30。因此，当前 8 项中这两项的“可导入”声明不可信。这里的 KWin `current` 是完成 modifier 查询后的集合，不是 EGL 原始格式查询的直接返回。

## v8 修复与本地验证

v8 只针对已固定 SHA256 的官方 3.1.0 / S30 私有测试栈，将既有缓存与当前查询的交集再限制到真实导入函数的 18 项表；预期保留 R8、GR88、RG16、AR24、AB24、XR24 六项。该表只是必要条件，真实 swapchain 导入、原生客户端、像素与呈现检查仍必须通过，所有错误检查保留。

新增回归必须直接复现本轮的 22→8 输入，再验证 8→6，且逐项比对未修改的厂商 ELF 导入表。仅通过原来的“查询已删除 XB24”模拟用例不足以交付。

新候选 `kwin-wayland-v8` / `desktop-userland-fix7-20261104` 已完成干净构建与链接，源包、补丁和实际构建工具均保存字节快照。manifest SHA256 为 `0451e520e6bc2372c9165e110f9358ca1bff06e56fa4d01e4dfba1ffa4254ae1`。

- 同一组 **35 项**用例分别在实际源码和最终库通过，不是 70 种不同用例。真实反例重现原始 22 项经 modifier 过滤为 8 项、再按导入表收窄为 6 项；同一断言在已固定的旧 v7 库退出 42、明确失败。
- 测试期望表从未修改的厂商 ELF 按 SHA 固定后提取，并与 18 个 Linux 格式常量逐项独立核对。其他驱动/型号旁路、modifier/external-only、空交集和查询异常检查保留。
- **64 项**恢复/负载/桌面流程测试通过；缺失、损坏或冲突的导入表版本记录会在客户端启动前被拒绝。真实 C++ 输出已通过 Python 日志解析检查。
- 私有 KWin(llvmpipe) + 客户端(softpipe) **60 帧、2,949,120 像素零差异，60 次呈现、零丢弃**。保存像素独立核验，软件结果明确不能作为 S30 硬件通过。
- 私有库暂存/依赖检查通过，无 RPATH/RUNPATH；沿用的客户端 EGL/glapi/测试程序逐字节未变。当前内核及已审阅桌面软件包版本未变，KDE active，mtgpu、测试服务/计时器及 watchdog inactive。

详细命令、哈希及验证边界见 [v8 验证记录](validation/userland-fix7-20261104/validation.json)。

补丁：[固定驱动导入格式约束](../patches/kwin-6.8.2-mtgpu-import-formats.patch)，SHA256 `a98fa9c7039e989798b80dd2f7d891abcfcae87c025a9bc08c8e556db51e666b`。厂商分支及纯 CPU 回放见 [分析](validation/userland-fix7-20261104/vendor-query-review/README.md)。

## 下一轮受控测试

**保存全部工作后，在自己的终端执行；此命令会退出 KDE 并计划重启。sudo 密码仅在本机输入。**

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

入口创建新 root/EFI 备份，核对默认启动文件、initramfs、版本与依赖，验证 watchdog 后才临时加载。不会安装开机驱动、替换系统 KWin/EGL，或修改启动项与 initramfs。旧 `20261104-200750` 只作证据，不用于 start。

本轮已观察到正常重启并核验原启动文件恢复；没有主动验证 watchdog 超时复位，不能保证所有硬挂死都自动恢复。黑屏先等待计划重启；若约 10 分钟仍无进展且 TTY 无响应，参照 [人工恢复说明](recovery/README.md#失败后的人工恢复) 在本机重启。

v8 真正的 S30 导入/绘制/呈现及 v6 display 桥接仍须下一轮实测；完整 Plasma、Xwayland、休眠恢复与长期稳定性未验收。
