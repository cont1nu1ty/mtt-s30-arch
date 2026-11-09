# 2026-11-04：v4 在配置枚举断言退出，启动恢复通过

最新测试 `20261104-111130`，内核 `7.2.14-arch1-1`，profile `kwin-wayland-v4`。**整体未通过；原生 Wayland 客户端在配置枚举阶段 SIGABRT，当前已正常恢复桌面并完成 EFI 恢复核验。**

## 本轮事实

- 模块成功加载并绑定 S30；Vulkan 8 帧/98,304 像素、H.264 48 帧硬解、EGL/GBM 8 帧/393,216 像素通过，导出后保存像素及完整视频字节独立复核通过。
- 私有 KWin 使用 S30、真实 DRM 节点及 HDMI 输出；未捕获此前着色器/图像导入故障。客户端退出 `-6`，仍未完成原生窗口绘制。
- 客户端日志包含 lookup-v1 与 opaque-screen 修复标记；在创建上下文前触发 `_eglSetConfigKey: Assertion offset >= 0 failed`。公共 context 回调路径本轮尚未执行。
- 内核加载至关机没有新增内核 BUG/WARNING/调用栈。11:12:14 的 WPS 相关进程异常发生在模块加载前、停止用户桌面期间，不计作 GPU 内核故障。
- 本轮新 EFI 备份审计通过；重启后 11 个文件中 10 个相同，仅 `loader/random-seed` 正常轮换，无新增/删除。当前桌面 active，mtgpu 未加载，临时服务、定时器及 watchdog inactive。
- 另发现 `20261103-142638` 已执行同一 v4，公共摘要同样记录客户端 `-6`；该历史轮详细输出及 EFI 未独立导出，不借用本轮结果代替它。

证据：[本轮复核](validation/runtime-20261104-111130/analysis.json)。

## 定位与处理

journal 中私有 EGL 的 `+0x8a08` 是断言调用返回地址，定位调用指令/PC-1 才能准确找到 `_eglSetConfigKey`；不能将后一个函数误认为崩溃原因。

厂商 `indexConfigAttrib` 枚举 52 项，其中含额外编号 54–59；该 Mesa 版本映射表有效下标是 0–53。原代码直接索引编号 56，越界读到相邻字符串字节，随后作为无效 EGL key 触发断言。修复须在索引前检查范围，跳过未知属性并继续处理后续标准属性，保留 `_eglSetConfigKey` 断言与全部配置验证。

这仍是用户态内部接口差异。Mesa 文档明确指出 [EGL 内部 ABI 不稳定](https://docs.mesa3d.org/egl.html)；相同版本字符串不能替代真实驱动数据验证。

## v5 修复与验证

补丁 `patches/mesa-23.2.1-dri-config-bounds.patch` 在读取映射表前检查属性编号，跳过未知值后继续枚举；保留原断言、配置验证、标准属性及循环上限。SHA256 为 `a234a74a360b1988d55f55f49a32961f470041a68558274ce6859c9849fde4d3`。

- 从准确 Ubuntu 源包干净重建，沿用此前 lookup-v1 / opaque-screen / public-context 修复；厂商二进制和 DRI 版本检查均未修改。
- 7 种实际库对照通过：用 core 导出的全部 54 个真实配置、厂商真实只读属性回调和最终 EGL 的 `dri2_add_config` 回放。旧库 raw 复现断言；旧库过滤未知字段的正对照、新库 raw、新库将未知编号改成 UINT_MAX 三者完整输出一致，保留 15 个有效窗口配置；非法渲染类型/深度仍被拒绝，非法 EGL key 仍触发原断言。未创建 screen/context/surface 或提交 GPU 工作。
- 54 项恢复、导出、桌面及负载流程回归通过；SIGABRT 崩溃导出严格保持 boot/程序/服务/UID 限定。
- 最终私有 EGL 与隔离软件 KWin 通过 60 帧、2,949,120 像素、零差异、60 次呈现、零丢弃；保存像素独立复核通过，软件结果不能通过硬件验收。
- 包版本、私有暂存及依赖、无 ELF RPATH/RUNPATH、模块哈希和正常桌面状态通过核对。内核模块与 KWin 保持本轮已使用版本。

最终候选为 `kwin-wayland-v5` / `builds/desktop-userland-fix4-20261104`，manifest SHA256 `04989706955b33380a844732845d61db97686eaf0bad1e23c4f1a6158cb4715e`。维护回放工具为 `maintenance/desktop/test-egl-config-abi.py`；完整命令和 45 个文件的哈希见 [准备记录](validation/userland-fix4-20261104/validation.json)。

## 下一步

保存工作后，通过受控入口新建 EFI 备份并审计，再测试 v5。将退出 KDE，约 3 分钟后请求重启：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

入口固定最终 v5 制品，继续核验真实 S30 renderer、DRM 输出、私有 EGL 路径、修复分支、像素和呈现反馈。不得复用本轮目录；不安装开机驱动、不修改启动文件或全局图形库。v5 的原生 S30 窗口仍未实测，完整 Plasma/Xwayland、长期稳定性和硬件 watchdog 到期复位仍未验证；严重挂死可能需要人工重启。
