# 第八轮：新内核负载通过，Wayland 客户端在 EGL 能力查询崩溃

2026-11-03，测试 `20261103-104000`，内核 `7.2.14-arch1-1`，profile `kwin-wayland-v3`。**整体未通过；已正常重启回到 7.2.14 桌面，输出及 EFI 恢复核验通过。针对本轮错误的 v4 修复已完成本地验证，可进入下一轮全新备份/审计与实测。**

## 当前已核验的证据

- 公共摘要记录模块成功加载并绑定 S30；Vulkan 8 帧/98,304 像素零差异，H.264 48 帧硬解零差异，EGL/GBM 返回成功。导出后独立复核 Vulkan 保存像素、全部 H.264 字节及 EGL/GBM 最终帧均通过。
- 私有 KWin/library 身份检查通过，renderer 为 MTT S30，打开真实 DRM 节点；未捕获此前的着色器或图像导入错误。原生客户端退出 `-11`，不能计为桌面通过。
- journal 确认 `egl-check` PID 24001 在私有 `libEGL_mesa.so.0 +0x1ea4b` 段错误，访问地址 `0x50`。从模块加载到关机未发现新增内核 BUG/WARNING/调用栈；客户端崩溃属于用户态错误。
- 10:43 请求计划重启，当前 boot ID 为 `9520fa64-c0d2-4c3a-9154-1597fdf1124d`，display-manager active；mtgpu 未加载，临时服务、定时器和 watchdog inactive。
- 本轮测试前新建了 7.2.14 的 EFI 备份并审计通过。**重启后恢复核验通过：11 个文件中 10 个完全一致，仅 loader/random-seed 正常轮换，无新增或删除。**

公共摘要与只读 journal：[证据目录](validation/runtime-20261103-104000/analysis.json)。

## 崩溃位置与修复方向

实际制品的调试信息将 `+0x1ea4b` 定位到 `get_screen_param()`，`egl_dri2.c:834`，内联于 `dri2_setup_screen()`。该代码将厂商返回的 opaque `__DRIscreen` 按 Mesa Gallium 私有 `dri_screen` 读取，再调用 `screen->base.screen->get_param`；崩溃指令为 `call *0x50(%r12)`。

这表明 lookup-v1 修复已允许初始化进入后续阶段，但相同 Mesa 版本字符串并不保证厂商私有对象布局一致。Mesa 也明确说明 [EGL 内部 ABI 不稳定](https://docs.mesa3d.org/egl.html)。实际 core 已确认错误读取产生 `pscreen=NULL`、API mask `2489709264`；厂商自己的 `getAPIMask` 读取值为 `0x1f`。同时确认 `DRI_Mesa.createContext=NULL`，公开 `createContextAttribs` 有效，原代码继续执行会再遇空回调。

现已对 mtgpu 使用公开 `getAPIMask` 和 `createContextAttribs`，保留上下文参数、共享对象与错误返回；不再解释厂商 screen 私有布局。缺少证明的可选能力不声明支持。额外修正 `MESA_drm_image` / `WL_bind_wayland_display`：厂商缺少名称导入回调及能力查询，不能沿 Mesa 默认值宣告支持。native linux-dmabuf 路径保留，其他驱动保留原行为。

core 调用栈及回调表见 [core-abi-review.log](validation/runtime-20261103-104000/core-abi-review.log)。这是静态/崩溃现场证据，回调非空不等于实际渲染成功。

## 第九轮候选与验证

- Profile：`kwin-wayland-v4`，目录 `builds/desktop-userland-fix3-v3-20261103`；manifest SHA256 `2c1805f9c9e0305fd7126a15cf156cfcbdc84745b4bba6597ef55aea64ee4c79`。
- 新补丁 `patches/mesa-23.2.1-mtgpu-screen-abi.patch` SHA256 `9d5683b8670f071241924b172d7e683030203f8f637c38b7972a7c264eb762fc`；准确 Ubuntu 源包重新校验、干净构建，DRI 版本检查及厂商二进制未修改。
- 22 项实际源码 ABI 回归通过：旧代码访问不可读 opaque 对象产生预期 SIGSEGV；新代码走公开回调；覆盖版本/空回调/API mask/能力声明/参数和错误透传，以及其他驱动原行为。测试源码/头文件哈希与最终编译版本完全一致。
- 52 项恢复、导出、桌面及负载流程回归通过。
- 独立软件 KWin + 最终私有 EGL：60 帧、2,949,120 像素、零差异、60 次呈现、零丢弃；保存像素独立复核通过，软件结果被硬件验收拒绝。软件控制使用 llvmpipe/softpipe，不能计为 S30 窗口通过。
- 私有文件暂存校验、依赖解析、无 ELF RPATH/RUNPATH、包版本及内核模块哈希通过。模块仍为本轮已验证的 `6857f52e…bc4adff`；KWin 二进制保持本轮使用版本。
- 下一轮验收除了真实 S30 renderer、DRM 输出和像素，还要求 lookup-v1、opaque-screen、public-context 三个分支标记与私有 EGL 路径。

完整构建/回归/软件命令及 32 项文件哈希见 [准备记录](validation/userland-fix3-20261103/validation.json)。中间 `desktop-userland-fix3-20261103`、`desktop-userland-fix3-v2-20261103` 不用于实测，入口只接受上述最终 manifest。

## 补齐本轮日志

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/collect-results.py /var/lib/mtt-s30-test/20261103-104000
```

此命令只复制日志、该隔离客户端的崩溃文件并核验 EFI，不加载驱动或重启。新增 core 导出严格匹配 boot、程序完整路径、服务、root UID 与 SIGSEGV，原文件不变；缺失时单独记录，不影响 EFI 判定。52 项恢复/桌面/负载/导出回归通过。

## 下一步

保存工作后，执行以下入口创建新的 EFI 备份并审计，再临时加载并测试。将退出 KDE，约 3 分钟后请求重启。不要复用 `20261103-104000`：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

恢复原则不变：每轮新建基线、临时加载、不自动安装/开机加载、不修改启动文件或全局图形库；硬件 watchdog 到期复位仍未经独立验证，严重挂死可能需要人工重启。v4 的 S30 原生窗口、完整 Plasma/Xwayland、长期稳定性和休眠恢复仍未验证。
