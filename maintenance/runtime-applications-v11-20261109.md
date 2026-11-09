# v11：重复窗口生命周期与 Qt Quick 验证准备

更新：16:08 的 v11 实机测试已通过五轮窗口生命周期和 Qt Quick，独立输出及 EFI 恢复复核通过。见 [实测记录](runtime-findings-20261109-160826.md)。以下保留测试前的准备与软件验证记录。

最近一次实机结果仍是 [v10 的隔离 KWin/Wayland 通过](runtime-findings-20261109-153310.md)：S30 完成 60 帧硬件呈现，客户端正常退出，Vulkan、H.264、EGL/GBM 和 EFI 恢复已复核。它证明了这台设备上的短时图形链路，尚不能代表完整 Plasma、XWayland、长期使用或可直接安装的 Arch 驱动。

本次准备 `kwin-wayland-v11`，尚未在 S30 执行。它沿用 v10 的内核模块和全部七个组件文件，增加应用负载，不改变启动配置。

## 下一轮实际过程

1. 建立新的 EFI 备份，核验当前 7.2.14 启动文件、模块/用户态哈希、软件包版本和 watchdog。检查失败即停止。
2. 退出 KDE，临时加载模块，复测 Vulkan、H.264 和 EGL/GBM。
3. 启动私有 KWin，由同一原生 Wayland 进程连续创建并完整销毁五组 EGL display、context、surface 和 Wayland 连接。每轮 60 帧，共 300 次呈现和 14,745,600 个像素检查；每轮检查 S30 renderer，要求全部硬件呈现反馈。
4. 在同一 KWin 内运行实际 Qt 6 Quick 测试程序，使用 OpenGL ES RHI 绘制 12 帧色块，检查 589,824 个像素、至少 12 次交换及 S30 上下文身份。记录私有 EGL/DRI 加载路径；窗口和整个 QGuiApplication 析构后才输出成功记录，进程退出码也必须为 0。
5. 再查 KWin/内核状态，结束私有会话，按既有监督流程重启。Qt 交换/读回不等同于硬件呈现反馈，也没有采集物理扫描输出的像素。

Qt Quick 测试主动请求 GLES 3；真实 plasmashell 默认请求桌面 OpenGL，路径不同。因此本轮即使通过，也不能直接填写“完整 Plasma 已验证”。XWayland、持续负载、休眠唤醒、安装/卸载与升级回退仍待各自测试。

## 本地验证

| 项目 | 本轮结果 | 证明范围 |
| --- | --- | --- |
| 恢复、日志和桌面流程回归 | 77 项通过 | 包括 Qt 异常退出、软件回退、缺失适配标记、像素错误、未完成销毁、客户端库进入 KWin、过长 socket 路径的拒绝 |
| EGL 生命周期与参数测试 | 12 项通过 | CPU 模式的 1/5/10 轮完整清理及非法参数拒绝 |
| 私有 KWin + 兼容 EGL 软件联合运行 | 五轮 300 帧及 Qt 12 帧通过；两个客户端退出 0，KWin 受控退出 15 | KWin 为 llvmpipe，客户端为 softpipe，不能作为 S30 结果 |
| 最终 RGBA 独立比较 | 两张图均逐字节符合预期 | 测试客户端读回正确，不是扫描输出截图 |
| 重建与暂存 | 两次构建逐字节相同；九文件清单、暂存权限、依赖与主机版本核验通过 | 可复现的本地候选 |

新制品：`../builds/desktop-applications-v11-20261109`；清单 SHA256：`8b6f7a9f028bac894b34a206b17a9755470e45b88e5e2b923122eab64cd18f64`。原 v10 制品和旧 root 测试目录保留。

本轮软件验证先暴露了两项测试流程问题：Qt 应用析构日志出现在结果之后；另一次测试目录过长，使 KWin 创建 UNIX socket 失败，并在失败清理时崩溃。前者通过调整结果输出顺序修复，后者通过启动前检查编码后的路径长度并使用短目录解决。最终完整复测通过；失败日志保留在验证记录列出的 work 目录。

[机器可读验证及证据哈希](validation/applications-v11-20261109/validation.json)。日志导出已增加 Qt 日志、RGBA/PNG 和仅匹配本次 root 测试进程的崩溃文件。

```bash
python3 maintenance/desktop/build-application-checks.py --output builds/my-applications-check
python3 maintenance/desktop/validate-userland.py \
  --bundle builds/desktop-applications-v11-20261109 \
  --stage work/v11-cpu-new \
  --software-root work/userland-fix-20261031/ubuntu-mesa
```

## 实机入口与恢复

保存工作后，在本机终端执行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

sudo 需要由用户在本机输入密码。命令会退出桌面并计划重启；它创建新的恢复基线，不复用旧 start 目录。驱动仅临时加载，不安装 DKMS 包，也不修改 initramfs 或启动项。下一次开机仍走原配置。

私有会话整体预算为 75 秒，各步骤超时不能累加延长该预算。原有约 180 秒正常重启、210 秒后备定时器保留，watchdog 的实际超时复位仍未证明。完全挂死时可能需要手动重启，具体步骤见 [恢复说明](recovery/README.md#失败后的人工恢复)。

## Arch 发布进度

本地 `mtgpu-s30-dkms 3.1.0-2` 内核与固件包已通过 makepkg 和私有 DKMS add/build；它尚未安装测试，也不含完成桌面所需的用户态修复。详情见 [内核包说明](arch/README.md)。完整包的安装、移除及内核升级恢复仍未验证。

这里按 AUR 文本配方准备，未向公开仓库提交。厂商闭源文件的公开再分发与用户态修补授权范围仍需明确；AUR 已有相关包，发布前也需比较其维护范围。这些事项与本机功能验证分别记录。
