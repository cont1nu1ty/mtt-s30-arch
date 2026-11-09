# 单次实机测试与恢复

**11 月 9 日 16:08 的 v11 实机测试已通过。** S30 完成五轮窗口和上下文的完整创建与销毁、300 次硬件呈现和 14,745,600 个像素比较，随后 Qt Quick 通过 12 帧、589,824 个像素比较；两个客户端退出码均为 0。四张末帧、完整 H.264 数据及 EFI 恢复独立复核通过。完整 Plasma、XWayland、长期稳定性与完整 Arch 安装包仍待验证。[v11 实测与边界](../runtime-findings-20261109-160826.md) · [v10 单轮结果](../runtime-findings-20261109-153310.md)

当前受控入口已切换至待实测的 v12，增加真实 Plasma 桌面、面板与 XWayland GLX。完整软件联测、107 项流程回归及两次一致构建通过；每次新建恢复基线，不安装驱动。[v12 准备与恢复安排](../runtime-plasma-v12-20261109.md) · [v11 准备记录](../runtime-applications-v11-20261109.md)。

2026-10-30：第五轮真实 Vulkan 绘制和 H.264 硬解通过；导出数据复核和 EFI 恢复核验通过。8 帧渲染零像素差异、48 帧硬解与 CPU 参考完全一致。详见 [第五轮结果](../runtime-findings-20261030-084900.md)。现有入口可复现该负载，不包含下一阶段的加速 KDE 测试。

## 重启后的默认处理

用户确认“重启完成”后，默认读取该轮公共摘要、内核与服务日志，核验是否回到原启动状态，并继续定位和修复未通过项，无需再次询问是否继续适配。需要受保护的图像、崩溃文件或 EFI 备份时，先完成可读部分的分析，再请用户在本机运行一次对应的只读导出命令。sudo 密码不进入聊天。

每轮新测试仍先完成本地验证和新的启动基线检查，再由用户保存工作后运行明确的测试入口。读日志和修复的默认授权，不等于在未准备好的制品上直接退出桌面或省略恢复检查。

## 隔离 Plasma/Wayland/XWayland 测试

v11 已完成实机验收；下面入口现在执行待实测的 v12。除原负载、五轮窗口生命周期与 Qt Quick 外，增加 Plasma 桌面/面板、活动服务、KIO 和认证私有 XWayland 的 GLX 应用。每次均新建恢复备份、核验启动项与 watchdog，并退出 KDE、临时加载模块、安排重启。[上一轮恢复结果](../validation/runtime-20261109-160826/recovery-result.json)

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

先复测已验证负载，再核验 EGL/GBM 和独立桌面会话；将退出当前 KDE，并计划重启。私有组件仅复制到新 root 测试目录，不替换系统 KWin/EGL。入口会核验库依赖、KWin/Mesa/Qt/Plasma/KIO/XWayland 等版本、默认启动项、initramfs 和 EFI 备份。软件自检不替代本轮 S30 实测。

私有桌面阶段限时 100 秒，超时对整组进程清理；180 秒计划重启与 210 秒后备重启保持不变。完整登录服务、锁屏、输出缩放、休眠和长期运行不在本轮验收范围。watchdog 超时复位仍未证明，严重挂死可能需要本机手动重启。

下面的 `--workloads` 仅用于复测第五轮，不启动 KWin：

保存工作后，在自己的终端运行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --workloads
```

此命令会退出 KDE，并在监督阶段约 3 分钟后请求重启。它先创建新备份、验证启动文件和所有测试制品、校准 watchdog，再临时加载驱动；不修改启动配置或安装自动加载模块。

详细负载、结果判定和证据见 [真实负载说明](../runtime-workloads-20261030.md)。不带 `--workloads` 的旧命令只做初始化枚举，不用于本轮验收。旧记录保留，结果导出仍用 `collect-results.py` 指向新生成的 root 备份目录。

## 历史记录：首次流程（以下旧命令不用于重试）

首次流程已经执行，**在加载显卡驱动前中止**。watchdog 倒计时 60→57、喂狗恢复 60 秒和启停检查通过；SDDM 于 15:32:32.767 停止，KWin 服务至 15:32:34.848 才完成退出，原版的立即检查过早。旧脚本没有记录 pgrep 的 PID/返回码，不能还原当时具体匹配进程，但退出时序与提前中止一致。

测试服务于 15:35:03 请求正常重启，15:35:46 系统重新启动；这不等于 watchdog 超时复位测试。服务的 stop-sigterm 超时/SIGKILL 是原监督进程在重启阶段保留 watchdog 并等待的退出策略导致，不能据此判定 GPU 挂死。

第一次导出的 Recovery verification 为 False，是全 ESP 比较包含了正常轮换的 `loader/random-seed`。逐文件核验确认：11 个文件中只有该文件改变，另外 10 个相同，无增加、无删除。修订后的 post-reboot 比较仍严格要求其他文件完全一致；加载前审计仍要求全部文件相同。第二次只读导出恢复核验通过，日志位于 `/var/tmp/mtt-s30-results-20261029-120000-x5glddyn`。

当时脚本已改为限时等待桌面和 DRM 使用者退出，要求连续两次空闲检查，并记录进程 PID/名称及 DRM 占用。检查命令出错或超时仍拒绝加载。恢复测试现为 19 项通过，当时尚未重新进行实机测试；第二次结果见本文顶部。

**下面旧时间戳的 start 命令只用于说明首次测试，不可直接用于重试。** 原 root 暂存目录及证据保留不改。后续测试须先用 `prepare-recovery.py` 创建新的当前启动基线及备份目录，再以新目录执行 start。

用户已于 2026-10-29 同意安排测试，条件是失败后仍可启动。当时尚未加载驱动。

2026-10-29 接手目录为 `/home/bull/Documents/mtt-s30-arch`，原 steven 目录保留。
当前只读检查：systemd-boot、ESP 挂载在 /efi，Secure Boot 关闭，mtgpu 未安装/未加载。
硬件存在 SP5100 TCO watchdog，当前 inactive、timeout=60、nowayout=0；PID 1 RuntimeWatchdogUSec=0。
这些属性只证明设备存在，不等于 watchdog 的打开、计时或复位已通过验证。没有打开 /dev/watchdog，也没有设置任何 watchdog 或重启计时器。

执行器用户无免密 sudo，不能访问受保护的 ESP。需要用户在自己的终端输入 sudo 密码，密码不通过聊天传递。

第一步运行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-recovery.py
```

这个脚本只检查和复制：

- 核对当前内核、现有模块状态、systemd-boot 当前启动项及其 kernel/initrd/UKI 文件。
- 将整个 ESP 备份到 root 专属的 `/var/lib/mtt-s30-test/<时间>/efi-before.tar`；逐文件核对备份内容，并确认备份期间原 ESP 未改变。
- 验证并暂存已经审阅的模块和官方 deb 到同一个 root 专属目录。
- 读取 watchdog 状态，不打开、启用或修改 watchdog。
- 写一份不含密码或密钥的可读摘要 `/var/tmp/mtt-s30-preflight-<时间>.json`，供助手继续检查。

脚本不会停止桌面、加载/安装模块、修改启动项或 initramfs，也不会安排重启。任一检查失败就停止。
2026-10-29 12:00 已执行完整 root 预检，备份位于 `/var/lib/mtt-s30-test/20261029-120000`。
12:25 接手审计通过：备份哈希与 ESP 文件一致、下次默认项仍是本次工作启动项、无待执行的 EFI 启动覆盖、initramfs 中无 mtgpu。摘要为 `/var/tmp/mtt-s30-audit-20261029-120000.json`。
LTS 只有工程内头文件和构建产物，并未安装为备用启动内核。第一次临时测试依靠现有主线内核及未改动的启动配置恢复。

## 已准备的单次测试

`test-once.py audit` 只读核验，绝不打开 watchdog。
`test-once.py start` 会再做审计，将脚本和厂商文件暂存到 root 目录，然后启动独立于桌面的临时系统服务。

**下面的 start 会结束当前 KDE 会话，并计划重启。保存全部工作后再执行：**

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/test-once.py start /var/lib/mtt-s30-test/20261029-120000
```

服务先验证 watchdog 的能力、超时回读、倒计时下降、喂狗刷新及关闭。失败时不加载 GPU；关闭 watchdog 失败可能需要提前重启。
验证通过后重新启用 watchdog，约 30 秒后停止显示管理器；确认 Wayland/X11 合成器退出、DRM 设备没有用户态占用后，将 ESP 临时重新挂载为只读，设置进程及本次启动范围的固件/库路径并加载已备份的模块。

历史两次流程使用 `39290bf0...d721558`，旧 root 暂存模块保持不改。当前新入口使用 `824b81aa…fb530a0c`，新建备份及测试目录；旧模块只允许重启后的结果审计，不允许开始新测试。
依次检查 PCI 绑定、render node、内核新增故障、管理工具、Vulkan 的 S30 PCI 身份、VA-API 接口枚举。任一失败就停止后续 GPU 检查，并记录失败退出码；软件渲染不算通过。枚举通过仍不证明实际渲染、视频解码或桌面稳定性。

从 watchdog 正式启用起约 180 秒请求正常重启，并设置独立的 210 秒重启定时器作为进程级后备。之后停止喂狗，保留硬件超时路径。系统正常关机过程可能接管 watchdog，因此这些时间不是“保证恢复桌面”的期限；目前 PID 1 的 RebootWatchdogUSec 为 10 分钟。
所有测试服务/定时器均为 transient，不设置开机重试，不安装模块，不更新 initramfs，不改启动参数，不关闭内核缓解机制。不尝试以 rmmod 恢复 simpledrm。

重启后先读公共摘要：

```bash
cat /var/tmp/mtt-s30-test-20261029-120000.json
```

然后导出有限范围的测试日志，并核对恢复到原启动配置：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/collect-results.py /var/lib/mtt-s30-test/20261029-120000
```

输出位于 `/var/tmp/mtt-s30-results-20261029-120000`，归执行 sudo 的普通账户所有，权限为 0700；原 root 日志不变。
collector 只读核验并复制选定日志，不会再加载驱动。若同名结果目录已存在，创建带随机后缀的新目录并保留旧导出。
若测试中止且没有重启，先查看公共摘要；不要直接重复 start，保留现场后检查原因。

## 失败后的人工恢复

若黑屏，先等待计划重启；仍有响应时可用 Ctrl+Alt+F3 登录文本控制台并执行 `sudo systemctl reboot`。
若超过约 10 分钟仍无进展且文本控制台也无响应，需要在本机按电源键强制关机后重新开机。重启后选择本轮备份记录的原 EndeavourOS/Arch 启动项（当前为 7.2.14-arch1-1）；不要安装驱动或重复旧 start。
若原启动项异常，保留错误信息后使用救援介质检查，不能盲目覆盖 ESP。备份路径如上。

软件定时器对完全失去调度能力的内核挂死无能为力；硬件 watchdog 也必须实际核验。仍需用户能够在本机执行必要的硬件重启，不能作绝对无故障承诺。

倒计时与启停验证不等于已经测试过硬件超时复位。本方案未主动制造硬挂死或断电试验。
接口依据：[Linux Watchdog API](https://docs.kernel.org/watchdog/watchdog-api.html)、[systemd 262 watchdog 设置](https://www.freedesktop.org/software/systemd/man/latest/systemd-system.conf.html#Hardware%20Watchdog)。

## 接手回归测试

`python3 -m unittest discover -s maintenance/recovery -p 'test_*.py' -v`：22 项通过，包含 4 项启动路径、15 项恢复/结果判定及 3 项新预检与加载入口衔接测试。
测试以临时目录和 mock 覆盖权限、默认启动项偏移、倒计时异常、DRM/桌面检查、Vulkan/VA-API 失败及软件渲染误判；不会操作实际 watchdog 或 GPU。它们不能替代 root 模式实机测试。
