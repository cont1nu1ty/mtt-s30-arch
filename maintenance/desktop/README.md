# EGL/GBM 和 Wayland 测试程序

**11 月 9 日 16:08 的 v11 实机测试已通过。** S30 完成五轮窗口和上下文的完整创建与销毁、300 次硬件呈现和 14,745,600 个像素比较，随后 Qt Quick 通过 12 帧、589,824 个像素比较；两个客户端退出码均为 0。四张末帧、完整 H.264 数据及 EFI 恢复独立复核通过。完整 Plasma、XWayland、长期稳定性与完整 Arch 安装包仍待验证。[v11 实测与边界](../runtime-findings-20261109-160826.md) · [v10 单轮结果](../runtime-findings-20261109-153310.md)

当前受控入口已切换至待实测的 v12，增加真实 Plasma 桌面、面板与 XWayland GLX。完整软件联测、107 项流程回归及两次一致构建通过；每次新建恢复基线，不安装驱动。[v12 准备与恢复安排](../runtime-plasma-v12-20261109.md) · [v11 准备记录](../runtime-applications-v11-20261109.md)。

v12 的 `build-plasma-checks.py` 组合已验证 v11 库、新 KWin 初始化修正、Qt 退出时序修正和 X11 GLX 程序。输出必须是新目录，`--kwin-work` 指向带完整 result.json 的重建记录。`validate-userland.py` 用 CPU 渲染测试整个私有会话，不接入当前桌面；软件结果不能通过 S30 硬件门槛。

```bash
python3 maintenance/desktop/build-plasma-checks.py --kwin-work work/p12-kwin-session-build --output work/NEW-v12-build
python3 maintenance/desktop/validate-userland.py --bundle builds/desktop-plasma-v12-20261109 --stage work/NEW-cpu --software-root work/userland-fix-20261031/ubuntu-mesa
```

`egl-check.c` 绘制动态色块并逐像素核对。`gbm` 模式必须打开 mtgpu render 节点；`wayland` 模式连接当前进程指定的独立会话，两者均要求 S30 renderer。软件验证模式仅用于测试程序自检，不能通过硬件结果判定。

仅构建 EGL 测试程序时，在工程根目录输出到新的目录：

```bash
python3 maintenance/desktop/build.py --output builds/my-desktop-test
```

需要本机 EGL/GLES3、GBM、libdrm、Wayland 开发头和 wayland-scanner，协议 XML 使用 Qt 安装目录。构建不会打开 GPU。每次源码或协议改变后必须重新构建、自检并审阅更新恢复模块中的 manifest 哈希；不覆盖已审阅的制品。

历史基础制品为 `builds/desktop-userland-fix1-v2-20261031`，profile `kwin-wayland-v2`。它增加私有 KWin、同版本 EGL/glapi，并保留错误阶段区分和实际库路径记录。历史构建使用 `build-userland.py`；联合软件验证使用 `validate-userland.py`。构建与测试命令、源包校验及恢复边界见 [第七轮说明](../runtime-userland-fix1-20261031.md)。这些旧制品保留，不用于当前实机重试。
