# KWin 6.8.2 / Mesa 26.2.6 升级后的复核

2026-10-31，用户执行 `yay -Syu` 后，`20261031-190526` 测试在旧 KWin 版本检查处停止。该次 EFI 备份和只读审计已通过；停止发生于创建测试暂存目录和启动服务之前。核对时显示管理器 active、mtgpu 未加载、watchdog inactive、mtt-s30-once.service 不存在。旧备份保留，不用于重试。

## 升级影响

| 项目 | 原版本 | 当前版本 / 处理 |
| --- | --- | --- |
| 正在运行及已安装内核 | 7.2.11-arch1-1 | 不变，headers 也未更新 |
| mtgpu 模块 | db8e4393…49143bb | 哈希不变，无需因本次用户态更新重建 |
| KWin | 6.8.1-2 | 6.8.2-1 |
| Mesa | 1:26.2.5-1 | 1:26.2.6-1 |
| Qt base / GLVND / libdrm | 6.12.0-3 / 1.7.0-3 / 2.4.134-1 | 不变 |
| Qt declarative | 6.12.0-2 | 6.12.0-3；随本轮新进程自检一起覆盖 |

比较了 KWin 两个标签下与本测试相关的 11 个源码文件。会话获取、Noop/logind、DRM 后端、DRM GPU、DRM EGL 后端及呈现反馈文件内容相同；其余四个文件的变化包括启动时输出 KWIN 环境、supportInformation 标题与环境信息、显示身份/DPMS、失败 EGL context 的提前返回、直接扫描输出设备检查。已有解析器不依赖变化的标题，SIGTERM 的 Qt 清理和正数 15 退出语义保持一致。测试仍关闭直接扫描输出。原始差异与哈希保存在证据目录。

升级确实涉及图形逻辑，不能仅因补丁版本号就认定兼容，参见 [KDE 6.8.2 官方变更记录](https://kde.org/announcements/changelogs/plasma/6/6.8.1-6.8.2/) 和 [Mesa 26.2.6 发行说明](https://docs.mesa3d.org/relnotes/26.2.6.html)。另比较了旧包和新安装 libgbm 的 38 个导出符号，集合没有增删；这不等于已证明所有内部 ABI 或硬件行为。

## 本机验证和修改

- 新 KWin 6.8.2 / Mesa 26.2.6 的独立虚拟会话：60 帧、2,949,120 个像素零差异，60 次呈现、零丢弃，无匹配的合成器图形故障，受控退出正常。
- 新 Mesa 的 surfaceless GLES：8 帧绘制/回读和独立像素核对通过。
- KWin、EGL 测试程序、H.264 测试程序及厂商 GBM 后端的动态依赖无缺失；私有厂商库环境下 KWin 6.8.2 命令行可启动。
- 40 项流程回归通过，包括新版本组合接受、未知 KWin/Mesa 版本拒绝，以及升级拦截发生在新备份之前。
- `verify_host()` 现在核验已审阅的 KWin 6.8.2-1 和 Mesa 1:26.2.6-1，失败时显示预期/实际版本。入口提前检查；原有暂存后和退出桌面前复核仍保留。

内核模块、测试 C 程序和两个 manifest 均未修改。这里的成功是升级后测试流程的软件参考验证；S30 的 EGL/GBM、真实 DRM KWin 和物理窗口呈现仍待用户执行第六轮实测。

## 重新开始

保存工作后再次执行同一命令。它将新建备份，旧 `20261031-190526` 保留：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

仍会退出当前 KDE，并在监督阶段约 3 分钟后请求重启；恢复边界、负载范围和验收条件见 [第六轮说明](runtime-desktop-20261031.md)。当前执行器仍需用户本人在终端完成 sudo 验证。

证据：`maintenance/validation/desktop-upgrade-6.8.2-20261031/`。升级前的软件自检和失败备份均不覆盖。
