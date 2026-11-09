# 2026-11-09：v12 推进至实际 Plasma，崩溃于 glGetGraphicsResetStatus 空分发槽

2026 年 11 月 9 日 17:05 的 `20261109-170542` 在内核 `7.2.14-arch1-1` 上执行了 `kwin-plasma-xwayland-v12` 实机测试。**整体未通过；基础负载、五轮原生 Wayland 窗口及 Qt Quick 全部通过，Plasma 启动阶段在 Qt Quick 渲染线程崩溃。本轮启动配置与 EFI 恢复核验通过。** [独立核验记录](validation/runtime-20261109-170542/analysis.json) · [输出复核](validation/runtime-20261109-170542/output-verification.json) · [崩溃诊断](validation/runtime-20261109-170542/diagnosis.json)

## 1. 已复核的实测证据

本轮使用 12 文件制品清单 `builds/desktop-plasma-v12-20261109`（SHA256: `d9d00ef849dab55a77e895a787194b6dfd04f2fdd724563666be4b353142b94a`）。私有 KWin 成功接管真实 HDMI-A-1 输出（1920×1080 / XR24），格式筛选与 DRM 交换链生效。

| 测试项 | 运行检查 | 导出后独立核验 | 状态 |
| --- | --- | --- | --- |
| Vulkan | 8 帧、98,304 像素零差异 | 末帧逐字节匹配 | 通过 |
| H.264 VA-API | 48 帧全部硬件解码 | 4,423,680 字节与 CPU 重新解码逐字节一致 | 通过 |
| EGL/GBM | 8 帧、393,216 像素零差异 | 末帧逐字节匹配 | 通过 |
| 原生 Wayland GLES | 5 轮各 60 帧，共 300 次硬件呈现、14,745,600 像素 | 请求/反馈完整配对，全部标志 7，末帧匹配 | 通过 |
| Qt Quick GLES | 12 帧、589,824 像素，14 次交换 | 末帧与公式逐字节匹配，PNG 解码一致 | 通过 |
| Plasma 桌面外壳 | Desktop OpenGL 4.3 成功初始化，文件夹桌面及面板生成 | `plasmashell` PID 30149 收到 SIGSEGV（11）退出 | **失败** |
| 退出与恢复 | KWin 按请求以信号 15 退出，无 forced kill；计划重启 | EFI 10 文件一致仅 random-seed 轮换，恢复核验通过 | 通过 |

### Plasma 桌面已到达的推进进度

`plasma.log` 与导出的 `plasma-before.json` 证实：
1. `mtgpu_dri.so` 成功为 `plasmashell` 建立了完整的桌面 OpenGL 上下文：`GL_VENDOR: Moore Threads`, `GL_RENDERER: MTT S30`, `GL_VERSION: 4.3 build 20250122_master-227-gdf7bc68e`。
2. 文件夹桌面（Screen 0, `org.kde.plasma.folder`）与默认面板（Screen 0, 高度 44，含启动器、任务栏、托盘、时钟等组件）已成功创建并绑定 D-Bus 对象。
3. Desktop 视图创建了 QRhi（`0x7f0b60001b60`）并建立了 `wl_surface#53`，进入输出并提交了 DMA-BUF 缓冲区。

## 2. 崩溃根因分析

从导出的 `plasmashell.core.zst`（SHA256: `112dceeaec3dd9101d06d278e1575d5012be272c325a6be5ff2580e266d865fc`）解压并还原调用栈定位：

1. **崩溃现场**：渲染线程 LWP 30186（`QSGRenderThread`）在执行 PC `0x0000000000000000` 时发生 SIGSEGV。
2. **调用链追踪**：
   - `#6 QRhi::beginFrame` → `#3 QOpenGLContext::makeCurrent` → `#2 QtWaylandClient::QWaylandGLContext::makeCurrent`
   - `#1 0x00007f0b92716a0b in QEGLPlatformContext::checkGraphicsReset() + 27`（`libQt6Gui.so.6`）
   - 反汇编显示 `call *%rax`，其中 `%rax` 为偏移 `0x78(%rdi)`，指向 `glGetGraphicsResetStatus` 入口桩。
3. **分发槽空指针**：
   - `libQt6Gui` 调用了 `libglapi_musa.so.0` 的 `glGetGraphicsResetStatusARB` 入口桩（`0x7f0b79429760`）。
   - 该桩通过 TLS 偏移 `-2720`（`musa_glapi_tls_Dispatch`）获取当前上下文的分发函数表（`0x55bc06c659f0`）。
   - 跳转指令为 `jmp *0x1a48(%r11)`（即偏移 `0x1a48`，对应 Mesa glapi 分发槽 841：`glGetGraphicsResetStatus`）。
   - 由于厂商 `mtgpu_dri.so` 未实现 `GL_ARB_robustness` / `GL_EXT_robustness`，在填充上下文分发表时将槽 841 留空为 `0x0000000000000000`，直接导致空跳转崩溃。

## 3. v13 修复方案与本地验证

更新 Mesa 兼容层补丁 `patches/mesa-23.2.1-mtgpu-gl-dispatch.patch`，实施双层安全防护：

1. **符号查询拦截**：在 `_eglGetClientGLProcAddress` 中拦截 `glGetGraphicsResetStatus`、`glGetGraphicsResetStatusARB`、`glGetGraphicsResetStatusEXT` 及 `glGetGraphicsResetStatusKHR`，统一返回安全的 dummy 函数 `s30_dummy_glGetGraphicsResetStatus`（返回 `0` 即 `GL_NO_ERROR`）。
2. **上下文分发表动态修补**：
   - 在 `src/egl/main/egldriver.h` 与 `egldriver.c` 中实现 `_eglPatchClientGLDispatchTable(void)`。
   - 动态获取当前活动分发表，检查 `libglapi_musa`（槽 841，偏移 `0x1a48`）及通用 `libGLdispatch`（槽 973，偏移 `0x1e68`）。若指针为 NULL，则强制填充为 `s30_dummy_glGetGraphicsResetStatus`。
   - 在 `src/egl/drivers/dri2/egl_dri2.c` 的 `dri2_bind_context` 完成后立即调用 `_eglPatchClientGLDispatchTable()`，确保无论客户端通过 `eglGetProcAddress`、dlsym 还是 Qt 内部虚表/TLS 分发调用，均不会落入空指针。

### 本地测试验证结果

- **Mesa EGL 构建通过**：重新编译 `libEGL_mesa.so.0`（SHA256: `36c8e7f91ddca0517972a80de208b7e405274481eb54a63208a1b69ee5bdb311`），分发补丁符号及反汇编插桩确认无误。
- **C 分发测试通过**：`maintenance/desktop/test-egl-gl-dispatch.py` 运行 6 个分发用例，覆盖 29 个 GL 入口点，`glGetGraphicsResetStatus` 各变体均正确返回 0。
- **107 项恢复与流程回归测试全部通过**：`python3 -m unittest discover -s maintenance/recovery -p 'test_*.py'` 耗时 10.188s，OK。
- **虚拟环境桌面联测通过**：`python3 maintenance/desktop/validate-userland.py` 确认私有 EGL/DRI 路径与用户态隔离运行退出正常。
- **候选制品就绪**：装配 `builds/desktop-plasma-v13-20261109`（清单 SHA256: `7d9e8aa3574ffecd34ae810baefb039411763d77445cd5017623e5b02b47cf40`），并在 `desktop_support.py` 中更新 profile 为 `kwin-plasma-xwayland-v13`。

## 4. 下一步：执行 v13 实机受控测试

硬件环境与测试配置均已就绪。请用户在主机终端执行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

该入口会自动完成以下保障机制：
1. 建立全新 root 与 EFI 备份，校验当前内核启动项与 initramfs。
2. 校验 v13 制品清单 SHA256 与独立监督器 watchdog。
3. 退出当前 KDE 会话，临时加载 `mtgpu` 驱动并执行 v13 桌面会话测试。
4. 测试完成后（或达到超时限制后）自动触发计划重启，恢复原始启动配置与显示管理器。

重启完成后回复“重启完成”，后续将直接检查测试日志与 EFI 恢复状态，继续推进桌面与 XWayland 验收。
