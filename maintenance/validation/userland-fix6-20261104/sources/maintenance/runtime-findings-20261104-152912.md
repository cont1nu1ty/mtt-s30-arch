# 2026-11-04：v6 在 KWin 启动阶段被 DMA-BUF 导入错误中止

最新实测 `20261104-152912`，内核 `7.2.14-arch1-1`，profile `kwin-wayland-v6`。**整体未通过；本轮启动和 EFI 恢复核验通过。原生 Wayland 客户端尚未执行，不能用本轮结果判断 v6 display 桥接修复的实机效果。**

## 本轮结果

- Vulkan 8 帧 / 98,304 像素、H.264 48 帧硬解、EGL/GBM 8 帧 / 393,216 像素通过；导出后的保存像素及完整视频字节独立核对通过。
- 私有 KWin 使用 MTT S30、真实 DRM 节点和 HDMI 输出；启动日志出现一次 DMA-BUF 导入失败，验收按原规则在客户端启动前中止。
- 错误图像为 `1920×1080`、`DRM_FORMAT_XBGR8888 (XB24 / 875709016)`、单平面、pitch 7680、offset 0、`DRM_FORMAT_MOD_INVALID`；EGL 返回 `EGL_BAD_PARAMETER`。
- 本轮没有客户端退出码、客户端日志或对应崩溃文件。不能把早期中止误写成客户端又发生 SIGSEGV。
- 模块加载至关机未发现新增内核 BUG/WARNING/调用栈。计划重启后正常 KDE active，mtgpu 未安装/未加载，临时服务/定时器及 watchdog inactive。
- EFI 11 个文件中 10 个相同，仅 `loader/random-seed` 正常轮换，无新增/删除。

证据：[独立复核](validation/runtime-20261104-152912/analysis.json)。

## 定位及证据边界

KWin 的 `EglDisplay::importDmaBufAsImage` 已正确省略 INVALID modifier 的属性；不能把这个值擅自改成 LINEAR。按 [Khronos 扩展规范](https://registry.khronos.org/EGL/extensions/EXT/EGL_EXT_image_dma_buf_import_modifiers.txt)，省略 modifier 和明确 LINEAR 不等价。

厂商主格式表有 18 项，不含 XB24；`createImageFromDmaBufs2` 在设备导入前扫描此表，缺失时返回 DRI 错误 3。modifier 查询反而识别 XB24，因此仅看 modifier 查询不能证明该格式可导入。

主格式查询在当前 primary GL context 为空时委托次级 musa 路径。bind/unbind 回调设置/清除对应 TLS 字段；历史客户端 core 的已初始化次级 screen 支持掩码及纯 CPU 回放显示该路径可返回包含 XB24 的 22 项列表。这是内部实现差异的证据，不能把历史 screen 掩码称作本轮 KWin 的实测掩码。

KWin 在 `EglDisplay` 构造期间查询并缓存格式，此时尚未创建当前 EGL context。后续输出格式选择沿用缓存，且 XR24/XB24 排序属性相同、没有固定平局顺序，可能受 QHash 初始顺序影响。启动存在主输出及 shadow swapchain 的逐格式试探，现有日志没有记录具体 producer 或最终成功格式；因此本轮仍判失败，不把它改判成已恢复的良性探测。

## 当前修复

新补丁让私有 KWin 仅对 mtgpu/S30 在 EGL context 成为当前上下文后重新查询 DMA-BUF 格式，并与原缓存取交集；不写死 XB24 黑名单，也不扩大能力。无法确认 modifier 的单个格式从刷新结果排除；完整格式查询失败、异常返回或可渲染交集为空则中止，不能继续使用原来的宽缓存。

候选为 `kwin-wayland-v7` / `builds/desktop-userland-fix6-20261104`，由原始 KWin 6.8.2 源包干净构建；保留 v6 的客户端 EGL、glapi 和测试程序不变。不改厂商二进制、不扩大能力、不把 INVALID modifier 改成 LINEAR。

补丁：[KWin 当前上下文格式修复](../patches/kwin-6.8.2-mtgpu-format-context.patch)，SHA256 `f298197f65595211d656d522b6eeb42f0e14393f164904a71425242eec6d07d1`。厂商分析、纯 CPU 指令回放和证据边界见 [记录](validation/userland-fix6-20261104/vendor-format-review/README.md)。

下一轮要求日志出现当前上下文的 accepted 集合，以及匹配已启用物理输出像素尺寸的正常 DRM-layer swapchain 成功记录；离屏 shadow、光标或复制缓冲不能代替主输出。仅为隔离进程启用两个诊断类别的 info 输出，所有既有图形错误检查保留。随后仍须通过原生客户端、硬件呈现标志和保存像素验证，成功打点本身不是完整桌面验收。

验证已完成：

- KWin 从原始源包干净构建、链接通过；库与程序无 RPATH/RUNPATH。最终 manifest SHA256：`d6220525b89a82a46b4e2d4f15b6cfd5fc6a0a0cc20a3b1cbe123bcf4d2811c6`。
- 同一组 29 项格式查询/交集/错误路径用例分别针对实际源码和最终共享库执行，均通过；不是 58 种不同用例。未初始化 GPU。
- 62 项恢复/负载/桌面流程测试通过，包含缺失/错误标记、shadow/cursor/复制路径不得冒充主输出、失败时保存证据。
- 私有 KWin 使用 llvmpipe、客户端使用 softpipe：60 帧、2,949,120 像素、零差异、60 次呈现、零丢弃；保存像素独立核验通过。明确拒绝把此软件结果作为 S30 硬件通过。
- 私有库暂存及依赖检查通过；客户端 EGL/glapi/测试程序与 v6 逐字节相同，保留对应旧回归证据。
- 当前内核仍为 7.2.14；KDE active，mtgpu 未安装/未加载，测试服务、计时器及 watchdog inactive。

详细命令、版本与哈希见 [v7 验证记录](validation/userland-fix6-20261104/validation.json)。本次实际使用的 builder 副本已归档；之后维护版增加构建输入快照与复制后校验，不改变本轮已验证二进制。

## 下一轮测试及恢复

**保存全部工作后，在自己的终端执行以下命令。它会退出 KDE，并计划重启；sudo 密码只在本机输入。**

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

入口创建新 EFI 备份，核对当前内核、默认启动文件、正常/备用 initramfs、依赖和 watchdog，然后临时加载。只使用新 root 测试目录，不安装开机模块、不替换系统 KWin/EGL、不修改启动项或 initramfs。旧 `20261104-152912` 目录仅作证据，不用于 start。

本轮已验证计划重启与原启动配置恢复，尚未主动验证 watchdog 超时复位，不能保证所有硬挂死都能自动恢复。黑屏先等待计划重启；若约 10 分钟仍无进展且 TTY 无响应，按 [人工恢复说明](recovery/README.md#失败后的人工恢复) 在本机重启。

v7 的实际 DMA-BUF 导入及 v6 display 桥接仍须 S30 窗口实测；完整 Plasma/Xwayland 和长期稳定性也未验证。
