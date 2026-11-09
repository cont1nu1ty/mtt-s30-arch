# v12：Plasma 桌面、面板与 XWayland 待实测

v11 已在 S30 上通过五轮原生 Wayland 窗口、Qt Quick、Vulkan、H.264 和恢复检查。v12 将下一轮推进到实际 Plasma 文件夹桌面、默认面板、活动服务与 KIO，并在 Plasma 存活期间运行 XWayland 的直接 GLX 客户端。**最终候选的软件联测与 107 项流程回归通过，v12 尚未在 S30 上执行。** [v11 实机结果](runtime-findings-20261109-160826.md) · [v12 本地验证](validation/plasma-v12-20261109/validation.json)

## 下一轮实际检查什么

仍先复测 Vulkan、48 帧 H.264 和 EGL/GBM，再启动私有 KWin，完成五轮原生 Wayland 窗口、共 300 帧，以及 Qt Quick 12 帧。随后启动系统实际的 plasmashell、ActivityManager 与 KIO，使用新建的私有配置、活动和 D-Bus；不读取用户当前桌面布局。

| 路径 | S30 实测通过条件 |
| --- | --- |
| Plasma 桌面与面板 | 文件夹桌面和默认面板实际存在，含启动器、任务栏、托盘和时钟；活动服务正常；使用桌面 OpenGL ≥ 3.3、S30 renderer 和指定私有 EGL/DRI；桌面及面板均提交 DMA-BUF |
| 面板交互 | 调整面板高度后恢复，布局与原值相同，面板有新的缓冲提交；应用测试期间 shell 持续运行 |
| XWayland 服务 | 必须是私有 KWin 的子进程，使用本轮独占 display 和认证文件；Arch 初始化 helper 成功；加载指定厂商 EGL/DRI，持有 S30 render node，无 glamor 软件回退 |
| X11 OpenGL 应用 | 直接 GLX、桌面 OpenGL ≥ 3.3，12 帧、589,824 个像素全部一致；DRI3 返回实际 S30 render node；完整销毁窗口、上下文和 display 后退出 0 |
| 退出与恢复 | Plasma 正常退出，KWin 按请求终止，无强制清理才能算功能通过；重启后单独核对启动文件、驱动状态与日志 |

这是完整桌面外壳与 X11 应用链路的短时测试。登录管理、锁屏、电源管理、音频、portal、用户自启动、输出缩放、热插拔、休眠和长期运行仍未验收。没有抓取 HDMI 扫描输出；Plasma 的证据是实际上下文、桌面/面板对象与缓冲提交，应用像素则另行读回比较。

## 本轮修正与本地证据

旧私有 KWin 构建把 libexec 路径设为 `/usr/lib/libexec`，而本机 Arch 的 XWayland helper 位于 `/usr/lib/plasma-setup-xwayland`。新构建使用正式 CMake 参数修正路径，并让这份私有验证构建仅运行该 helper，检查其五秒内正常退出 0。XWayland 初始化不执行系统 `Xwayland-session.d` 中的用户环境和输入法启动脚本。原 v11 源码、构建树和九文件制品逐项恢复、校验未变。[源码差异](validation/plasma-v12-20261109/kwin-private-xwayland-startup.patch) · [构建记录](validation/plasma-v12-20261109/kwin-build-result.json)

首次整体软件联测还暴露 Qt 检查程序的退出时序：12 帧像素已读回，最后一次交换信号尚未到达。现等待原有交换门槛满足后再退出，仍受原十秒 watchdog 限制，不放宽像素、交换和应用清理检查。失败现场保留在 `work/v12-cpu`。

最终候选 `builds/desktop-plasma-v12-20261109` 含 12 个载荷文件，manifest SHA256 为 `d9d00ef849dab55a77e895a787194b6dfd04f2fdd724563666be4b353142b94a`。第二次独立构建逐文件一致，暂存权限和运行依赖通过，已固定当前 KWin、Mesa、Qt、Plasma、KIO、XWayland 等版本；升级后必须重新审阅，不能跳过版本门槛。[制品清单](validation/plasma-v12-20261109/desktop-manifest.json)

- 107 项恢复、负载与桌面流程回归通过，包含 5 项真实进程组清理测试；超时、忽略 TERM、组长先退出、中断和非零退出均有覆盖。[测试输出](validation/plasma-v12-20261109/flow-tests.log)
- 新 KWin 最终库的 35 项格式回归通过；5 项初始化错误入口测试使用实际替换函数与 stub 对象，通过拒绝无效目录和 helper 路径。[格式回归](validation/plasma-v12-20261109/kwin-format-tests.json) · [初始化保护](validation/plasma-v12-20261109/kwin-startup-guards.json)
- 最终整体软件会话通过：原生 Wayland 五轮 300 帧、Qt Quick 12 帧像素检查与 13 次交换、Plasma 桌面 OpenGL 3.3、面板调整恢复、XWayland GLX OpenGL 4.6 的 12 帧。三份 RGBA 末帧与独立公式逐字节一致，Qt PNG 也匹配；Plasma 退出 0，GLX 客户端退出 0，KWin 按请求退出 15，无私有会话残留进程。[完整会话结果](validation/plasma-v12-20261109/software/desktop-session-result.json)

软件对照明确使用 softpipe/llvmpipe，软件会话的呈现标志不能作为硬件证据。S30 DMA-BUF、厂商 XWayland 加速及 DRI3 硬件分支仍须下一轮实测。原始日志中隔离服务的 ServiceUnknown 等消息保留，不据此宣称完整登录环境已通过。

## 恢复安排与执行

本轮仍用已通过 v11 的 `7.2.14-arch1-1` 模块，SHA256 `6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff`。入口会先创建新的 root/EFI 备份，检查默认启动项与 initramfs，核验制品及 watchdog。失败便停止后续步骤。通过后退出当前 KDE，临时加载驱动；不安装开机模块，不修改内核、initramfs、启动项或系统 KWin/EGL。

私有桌面阶段总限时 100 秒，超时后对整个进程组发 TERM/KILL，另最多约 4 秒收尾。之前的停止桌面、驱动加载和负载检查不包含在这 100 秒内；若前面耗时过长，独立监督器可以提前结束测试。原 180 秒计划重启、210 秒后备重启和系统服务 cgroup 保持不变，不为完成测试延长恢复期限。

当前负载不改变输出缩放。KWin 的缩放变化路径仍可 detached 启动 helper，新增缩放或热插拔测试前须处理这一例外。私有 HOME、XDG 和 D-Bus 隔离的是会话配置与自动激活，并非系统总线沙箱。

watchdog 倒计时和启停已在先前轮次验证，硬件超时复位仍未证明。极端内核挂死可能需要本机手动重启；正常重启继续使用本轮核验的原启动配置。[人工恢复步骤](recovery/README.md#失败后的人工恢复)

保存工作后在本机终端执行，sudo 密码由用户本人输入：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

重启后回复“重启完成”即可。默认读取公共摘要与日志、核验恢复，并继续修复失败项；仅在受保护日志确实需要导出时提供对应的只读命令。本轮新 root 备份和启动审计将在上述入口执行时完成，目前未启动新实机测试。
