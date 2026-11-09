# 2026-11-04：v5 配置修复生效，Wayland 窗口创建仍失败

最新实测 `20261104-112910`，内核 `7.2.14-arch1-1`，profile `kwin-wayland-v5`。**整体未通过；启动及 EFI 恢复已核验。** 新崩溃发生在窗口创建，不能继续使用 v5 重复实测。

## 已复核的结果

- Vulkan 8 帧 / 98,304 像素、H.264 48 帧硬解、EGL/GBM 8 帧 / 393,216 像素通过；导出后保存的像素及完整视频字节独立复核通过。
- 私有 KWin 使用 S30 和真实 DRM/HDMI 输出。未捕获此前的着色器及图像导入错误；启动阶段探测留下的 `EGL_NOT_INITIALIZED` 仍保留在原始日志，没有隐藏。
- 私有 EGL 的 lookup-v1、opaque-screen、配置范围检查、public-context 标记全部出现；成功枚举 15 个窗口配置并创建上下文。上一轮 `_eglSetConfigKey` 断言未再出现。
- 客户端 PID 24369 在 `eglCreateWindowSurface` 内 SIGSEGV。调用链为 `dri2_create_drawable` → 厂商 `createNewDrawable` → `xcb_get_window_attributes` → `xcb_send_request_with_fds64`。
- 加载驱动至关机未见新增内核 BUG/WARNING/调用栈。停止原桌面时，系统 KWin PID 1481 的 Qt 清理路径在 11:29:53 崩溃；该事件早于 11:29:57 模块加载，与 11:30:02 隔离客户端崩溃分开记录。
- 当前重新启动到 `7.2.14-arch1-1`，KDE active；mtgpu 未加载，临时服务/定时器及 watchdog inactive。EFI 11 个文件中 10 个不变，仅 `loader/random-seed` 正常轮换，无新增/删除；恢复核验通过。

证据：[本轮复核](validation/runtime-20261104-112910/analysis.json)。导出崩溃文件 SHA256：`34a07011cd1f156238d6b29c77d35a1e8cf3ff0a797ba215edde73a8dc367efe`。

## 当前定位

core 显示厂商 XCB 分支收到的“连接”实际上是 Mesa `_EGLDisplay *`，来自 Wayland surface 的首字段。厂商 screen 初始化代码按旧 display 布局读取 platform/native-display；当前私有 Mesa 对应字段偏移不同。需要同时审阅 display 私有布局、loader 回调参数及窗口分支，不能只增加 DRI2 loader 来绕过当前崩溃：render node 的图像共享语义仍必须保留。

Mesa 官方说明 [EGL 与驱动之间的内部 ABI 不稳定](https://docs.mesa3d.org/egl.html#packaging)。这里的版本字符串检查没有取消，但相同字符串不足以保证厂商内部结构一致。

## v6 修复与验证

`patches/mesa-23.2.1-mtgpu-display-abi.patch` 为已审阅的 x86-64 mtgpu Wayland 路径提供独立 display 前缀：按厂商偏移传递平台及 native display，保存真实 display 用于回调翻译。该结构嵌入 display 私有数据，直到两个 DRI screen 销毁之后才释放；原 Mesa display、锁和 surface 参数保持不变。图像查找仍进入原资源验证器。没有增加 DRI2/GEM-name loader、修改厂商二进制或跳过 ABI 版本检查。

- 8 项实际 EGL 库对照通过：旧库重现错误平台偏移；新库保持原 display 完整内容、非 mtgpu/非 Wayland 路径不变；有效/无效/跨 display 的图像校验、创建失败清理及销毁期存活正确。设备创建/销毁使用测试回调，未初始化 GPU。
- 4 项厂商二进制分支回放通过：旧库选择 X11 类型 0 / XCB，新库选择 Wayland 类型 4 / image。调试器在设备初始化前终止进程；drawable 的次级 musa 构造仅使用进程内记录桩，不代表真实窗口创建成功。另有 4 项系统调用拦截负向验证通过。库加载及扩展发现发生在防护启用之前，被测构造函数处于防护范围内。
- 7 项真实配置回放通过：54 个配置仍保留 15 个有效窗口配置，非法配置/键仍被拒绝。
- 55 项恢复、导出、桌面及负载流程测试通过。公共摘要现在会保留客户端崩溃前已到达的兼容分支，减少定位所需的重复日志导出；这些标记本身不构成绘制通过。
- 最终库与隔离软件 KWin 完成 60 帧 / 2,949,120 像素、零差异、60 次呈现、零丢弃；保存像素独立核对通过，软件结果仍不能通过硬件验收。
- 模块及系统包版本、暂存制品哈希、依赖和无 RPATH/RUNPATH 检查通过；驱动未加载，临时服务/定时器/watchdog inactive，正常 KDE active。

最终候选 `kwin-wayland-v6` / `builds/desktop-userland-fix5-20261104`，manifest SHA256 `7f1c07cd2482ab41d6eb14247b2241309119064611bec4bb6ce65f83def2cf56`，EGL SHA256 `1745f0903656a0a4a6b764313fb56eff988ba7855ecd66278e1128153ce2f6dc`。完整命令与 93 个文件的哈希见 [v6 准备证据](validation/userland-fix5-20261104/validation.json)。本轮实测诊断另有 57 个文件的哈希；旧轮证据保持不变。

## 下一步

v6 已准备好进行一轮受控实测；实际设备创建、缓冲区分配、绘制提交和硬件退出尚待确认。保存工作后运行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

该入口新建 root/EFI 备份、核验启动文件及 watchdog，再退出 KDE 临时测试并计划重启。不持久安装模块，不修改系统图形库及启动文件；不要复用旧 root 测试目录。

完整 Plasma/Xwayland、长期稳定性与硬件 watchdog 到期复位仍未验证；本轮正常重启不是硬件强制复位试验。
