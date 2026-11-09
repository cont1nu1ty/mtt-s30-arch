# MTT S30 / Arch 驱动适配交接

交接时间：2026-11-09 17:15，Asia/Shanghai。本文面向能读取本机工程的后续助手，不依赖之前的聊天或 Codex 专用工具。时间戳是现场快照，接手时必须检查是否已有更新一轮测试。

项目根目录：`/home/bull/Documents/mtt-s30-arch`。当前维护账户为 `bull`；旧 `/home/steven/项目/mtt-s30-arch` 不是继续工作的目录。项目目前没有 `.git`，不要假定能用 Git 恢复覆盖的文件。

## 1. 先读结论：现在停在哪里

目标是在本机 Arch/EndeavourOS 上适配摩尔线程 MTT S30，完成真实图形、视频、Plasma/Wayland/XWayland 和可恢复运行，再考虑完整 Arch 打包及 AUR。用户最重要的约束是：**测试失败后仍能回到原启动配置，不能以适配为由破坏正常启动。**

**最后完整独立验收通过的是 v11；最新实机尝试是 v12，已执行且失败在 Plasma 启动。** 不要继续沿用旧准备记录里的“v12 尚未实测”。

| 状态 | 具体证据与边界 |
| --- | --- |
| v11 完整通过 | `20261109-160826`：基础负载、五轮原生 Wayland 窗口/上下文/连接生命周期，共 300 次硬件呈现及 14,745,600 个像素比较；Qt Quick GLES 12 帧、589,824 个像素；客户端退出 0；图像、完整视频与 EFI 恢复独立复核通过 |
| v12 最新尝试 | `20261109-170542`，profile `kwin-plasma-xwayland-v12`。模块、Vulkan、48 帧 H.264、EGL/GBM、五轮原生窗口和 Qt Quick 均通过运行时检查；Qt 为 12 帧、14 次交换、MTT S30，退出 0 |
| v12 当前失败 | `kwin-session=1`、`probe_exit=1`，错误 `Plasma workspace process exited during startup.`。17:06:48 的 journal 确认测试服务中的 `/usr/bin/plasmashell` PID 30149、UID 0、SIGSEGV（11） |
| 崩溃线索 | 渲染线程 30186：PC `0x0` → `QtWaylandClient::QWaylandGLContext::makeCurrent(QPlatformSurface*)`，`libqt-plugin-wayland-egl.so + 0xbee4` → `QOpenGLContext::makeCurrent` → `QRhi::beginFrame`。只读到 journal 调用栈，尚未读取完整 core，根因未确认 |
| KWin 与内核 | 摘要中 KWin 为 S30 / HDMI-A-1 / 1920×1080 / XR24，格式筛选有效；按请求退出 15，无 forced kill，`compositor_faults=[]`、`kernel_faults=[]`。这些是本轮摘要结果，不等于无任何残余消息 |
| XWayland | 尚未进入 GLX 应用验收。不能写“XWayland 已通过”，也不能把 Plasma 崩溃写成 XWayland 失败 |
| 当前系统 | 17:15 核对：`7.2.14-arch1-1`，KDE active，mtgpu 未加载、modinfo 未找到安装项；临时服务/定时器、watchdog inactive，临时固件路径为空 |
| 当前恢复边界 | 已发生重启并回到 KDE，但 **v12 本轮 EFI 恢复尚未独立核验**，没有该轮日志导出目录。不能借用 v11 的 Recovery True |

测试 boot ID：`ba558900-3338-45c9-a700-514e4acdce87`。交接时当前 boot ID：`4fd8b8ae-7e86-42bd-adea-ebea071a0e49`。

本次交接保存了公共摘要、预检/审计记录、限定范围 journal 和当前状态：[现场快照](validation/handoff-20261109/preliminary-review.json)、[测试服务日志](validation/handoff-20261109/previous-test-service.log)、[当前系统](validation/handoff-20261109/current-state.json)。它们不是 root 日志导出的替代品。

优先阅读顺序：本文 → [v11 实测报告](runtime-findings-20261109-160826.md) → [v12 准备说明](runtime-plasma-v12-20261109.md) → [恢复流程](recovery/README.md) → 具体失败涉及的源码。`maintenance/validation.json` 当前仍停在 v11 完整通过、v12 准备完成的快照；不要让该旧汇总覆盖本节的新现场。

## 2. Gemini 接手后的第一件事

先完成已有失败的日志与恢复核验，**不要直接重复未修改的 v12，也不要安装驱动。**

需要用户在自己的终端执行一次只读导出：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/collect-results.py /var/lib/mtt-s30-test/20261109-170542
```

说明原因：完整 Plasma/活动服务/KIO 日志、崩溃文件和 EFI 备份归 root 所有，当前执行器没有免密 sudo。密码只在用户本机输入，不进入聊天。此命令不会退出桌面、加载驱动或重启。若返回带随机后缀的导出目录，以实际输出为准，不假定固定目录名。

导出后重点检查：

1. `recovery-result.json`：本轮 boot ID、当前默认启动项、内核/initramfs、EFI 差异及模块状态。Recovery False 必须解释具体差异，不能忽略。
2. `plasma-result.json`、`plasma.log`、`plasma-activities.log`、`plasma-kio.log`，确认失败进程、实际上下文/API、已到达的兼容分支和退出方式。
3. 本轮 `plasmashell` core 与确切 ELF/库：按本轮 manifest、实际加载路径和 SHA256 匹配，定位 `makeCurrent` 的空调用来自哪个函数指针或分发入口。系统 Qt 插件和私有 EGL/DRI 的版本都要匹配。
4. 比较已通过的 Qt Quick GLES 与失败的 Plasma 默认桌面 OpenGL/渲染线程路径。GL API、分发库及线程上下文是排查方向，**不是已确定根因**；不要直接强制软件渲染或强制 GLES 后把原目标判为通过。
5. 独立复核本轮保存的图像/视频与退出记录，确认运行的是预期 v12 制品；公共摘要通过不是导出后复核的替代品。

如果 collector 未找到本轮 core，先读它返回的精确原因，并核对本轮 PID/boot/unit/EXE。不要放宽为复制所有 root core。正式复核完成后，新建该轮 `runtime-findings` 报告及证据目录，再更新当前汇总，保留准备阶段快照。

## 3. 适配过程与关键转折

| 时间/阶段 | 实际遇到的问题 | 修复及学到的边界 |
| --- | --- | --- |
| 10 月 29 日，构建阶段 | 官方桌面驱动 3.1.0 的旧内核接口不能直接用于现代 Arch | 完成接口探测、VFS、IOMMU、DRM、定时器等兼容；7.2.11 与 6.18.58 LTS 构建/链接/符号检查通过。编译通过只是起点，LTS 从未安装或运行 |
| 首次受控测试 | 停 SDDM 后 KWin 还在退出，误判桌面未停止 | 有上限等待图形进程和 DRM 用户退出，连续两次空闲才加载；这是测试流程问题，不是 GPU 初始化失败 |
| 初始化第 2～4 轮 | workqueue flags、新旧显示接管、DISPC 完成通知和 VPU MMIO 映射冲突 | 覆盖全部 6 个直接 workqueue 调用；调整 BOOTFB 移交；S30/GEN1 显示关闭按硬件完成位轮询；约束 VPU 映射，保留 TOP/core 区并核对资源。初始化和接口枚举通过 |
| 10 月 30 日，真实负载 | 枚举不证明 GPU 真正执行任务 | Vulkan 8 帧与 H.264 48 帧硬解通过，导出视频 4,423,680 字节与 CPU 参考一致 |
| Wayland v1→v2 | 厂商 EGL 缺现代设备反馈，KWin GLES 着色器与共享内存路径不兼容 | 使用准确来源的 Ubuntu Mesa EGL 构建私有协议兼容层，保持 ABI 检查；修 KWin GLES shader，隔离会话禁用 udmabuf 优化，真实 DMA-BUF 仍必须通过 |
| v2→v3 | 厂商 screen 入口拒绝 DRI_IMAGE_LOOKUP v2 | 仅针对 mtgpu Wayland 提供完整 v1 回调，保留资源校验。系统升级后正常启动 7.2.14，重新构建模块和建立恢复基线 |
| v3→v4 | 将厂商 opaque screen 当成 Gallium 结构解引用，发生 SIGSEGV | 改走公开 getAPIMask/createContextAttribs 回调，未知能力不宣告。相同 Mesa 版本字符串不保证私有布局一致 |
| v4→v5 | 厂商配置属性编号越界，触发 Mesa 配置断言 | 在数组索引前做范围检查，跳过未知属性，保留标准配置校验和断言；不是禁用断言 |
| v5→v6 | display 结构偏移不一致，Wayland 窗口误走 XCB，收到错误“连接”指针 | 增加受限 display ABI 前缀桥接和回调翻译；桥接对象直到两个 DRI screen 销毁后才释放，不修改原 Mesa display 所有权 |
| v6→v7→v8 | KWin 导入 XB24 返回 EGL_BAD_PARAMETER；context current 后重新查询的 v7 假设被实机否定 | 次级 context 不设置主 TLS，查询仍含不能导入的格式。v8 将查询结果约束到固定厂商真实 18 项导入表，得到六项允许格式；S30 HDMI 的 XR24 输出成功 |
| v8→v9 | EGL 创建/绑定成功，首次 GL_RENDERER/GL_VENDOR 查询却为空 | Mesa 与厂商 GLAPI 使用不同线程分发表；私有客户端统一使用指定厂商入口，包含公开 GL 和内部 glFlush。实机首次呈现完整 60 帧 |
| v9→v10 | 60 帧后 eglDestroySurface 重复释放，SIGABRT | 真实 WaylandSwapChain 析构重复调用基类；仅客户端专用 mtgpu_dri.so 副本修两条各 5 字节指令。原库/修复库实际析构 + ASan 对照后，实机创建、绘制、销毁、退出与恢复通过 |
| v11 | 验证更完整生命周期和 Qt 应用 | 五轮完整连接/窗口/上下文、300 次硬件呈现及 Qt Quick 全部通过并独立复核 |
| v12 准备 | 增加真实 Plasma 与 XWayland，暴露测试基础设施问题 | 修正 Arch XWayland helper 路径和私有启动脚本目录；整组超时清理；Qt 等最后交换再退出。107 项流程回归、35 项 KWin 格式回归、完整软件会话通过 |
| v12 实机最新 | 既有负载继续通过，Plasma makeCurrent 链路 SIGSEGV | 当前待定位问题；XWayland 应用验收未到达，详细导出和本轮 EFI 核验待做 |

历史原始证据集中在 `maintenance/runtime-findings-*.md` 与 `maintenance/validation/runtime-<时间>/`。关键报告：[内核修复](runtime-fix3-20261029.md)、[display ABI](runtime-findings-20261104-112910.md)、[v7 反例与格式表](runtime-findings-20261104-200750.md)、[GL 分发](runtime-findings-20261105-144027.md)、[重复析构](runtime-findings-20261109-150112.md)、[v10 通过](runtime-findings-20261109-153310.md)。

## 4. 工程地图与固定制品

以下路径相对项目根目录；不要混淆根 `patches/` 与 `maintenance/patches/`。

| 路径 | 用途 |
| --- | --- |
| `official/musa_3.1.0-pc_x86.deb` | 官网桌面驱动原包，不是 MUSA SDK 5.2.0 |
| `official/driver-3.1.0/` | 原包解包，不执行其安装脚本、不直接修改 |
| `work/mtgpu-3.1.0/` | 内核维护源码；相应修改通过 export_patch.py 导出 |
| `maintenance/patches/linux-modern.patch` | 完整内核兼容补丁；根 `patches/linux-modern.patch` 不存在，旧说明中若有该路径应纠正理解 |
| `maintenance/{prepare.py,build.py,export_patch.py}` | 原包校验、补丁与干净重建工具 |
| `maintenance/tests/` | 内核兼容层和初始化回归；14 项为历史已通过结果，不替代硬件 |
| `patches/mesa-23.2.1-*.patch` | 私有 EGL/DRI ABI、配置、display、GL 分发补丁 |
| `patches/kwin-6.8.2-*.patch` | KWin GLES 与导入格式修正 |
| `maintenance/desktop/` | EGL/Wayland/Qt/X11 检查程序、私有库构建、ABI/析构/格式测试和软件对照 |
| `maintenance/desktop/build-drawable-compat.py` | 原始指令和整库哈希约束下的客户端 DRI 析构修复 |
| `maintenance/desktop/build-kwin-session-compat.py` | 从准确 v11 源码/构建树重建私有 KWin，恢复旧树；不是系统 KWin 安装工具 |
| `work/kwin-import-table-final-20261104/` | 准确 v11 KWin 源码/构建基线。不要误用更早的 format-context 树 |
| `work/p12-kwin-session-build/` | v12 KWin 新库、补丁、构建记录与恢复证明；执行版 builder 快照与当前维护入口可能不同，以结果哈希区分 |
| `maintenance/desktop/build-plasma-checks.py` | 组合 v11 库、新 KWin、Qt/X11 程序与 Plasma/XWayland helper，生成完整候选 manifest |
| `maintenance/recovery/{prepare-recovery.py,test-once.py,prepare-and-test.py}` | 新恢复基线、审计、watchdog/临时服务和受控入口 |
| `maintenance/recovery/{desktop_support.py,plasma_support.py,xwayland_support.py,session_process.py}` | 桌面验收、应用检查、私有 X 认证及整组进程超时清理 |
| `maintenance/recovery/collect-results.py` | 只读白名单导出、精确 core 选择与启动恢复复核 |
| `maintenance/validation/` | 各轮原始输出、分析、源码/制品/证据哈希；失败记录也必须保留 |
| `maintenance/arch/`、`work/arch-package-20261109/` | 实验内核/固件配方与私有 DKMS 构建证据，不是完整驱动部署 |
| `/var/tmp/mtt-s30-{test,preflight,audit}-<时间>.json` | 可读的测试、预检和审计摘要 |
| `/var/lib/mtt-s30-test/<时间>/` | root 专属新备份及暂存现场，普通助手不可直接读取 |
| `/var/tmp/mtt-s30-results-<时间>[-后缀]/` | 用户 sudo 导出后可读的本轮证据 |

当前关键 SHA256（交接时核对过工程文件；本轮 root 暂存 manifest 仍需导出核对）：

```text
官方 deb
04c286ba452fe0cfbea2c47465f0c48b0659c09b896f05f363feba680dd8efda

已验证 7.2.14 模块
builds/runtime-fix3-v2-7.2.14-20261103/source/mtgpu.ko
6857f52e14db1071ca5b089029725432d5bbb71022dba55f9cd973121bc4adff

v11 manifest：builds/desktop-applications-v11-20261109/manifest.json
8b6f7a9f028bac894b34a206b17a9755470e45b88e5e2b923122eab64cd18f64

v12 manifest：builds/desktop-plasma-v12-20261109/manifest.json
d9d00ef849dab55a77e895a787194b6dfd04f2fdd724563666be4b353142b94a

客户端修复后主 DRI（不是官方原版）
05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23
```

当前固定版本由 `desktop_support.REVIEWED_DESKTOP_PACKAGES` 定义：KWin/Plasma 6.8.2-1，Mesa 1:26.2.6-1，Qt base 6.12.0-3、declarative 6.12.0-4，XWayland 24.1.14-1 等。完整字典和候选 manifest 是校验依据，不要手抄一部分后删除其余保护。`yay -Syu` 后必须重新审阅；不能仅改常量让检查通过。

## 5. 每轮必须保持的工作流程

### A. 重启后默认继续分析

用户已明确：**以后说“重启完成”，默认读日志、核验恢复并继续适配，不再询问是否继续。** 先做可读检查；确实缺 root 证据时一次性给出具体只读导出命令，说明权限原因。不要把工作停在“需要日志”，可读的调用栈和源码应继续分析。

下面只读取当前状态及最新公共摘要，不会停止桌面或加载驱动：

```bash
cd /home/bull/Documents/mtt-s30-arch
python3 - <<'PY'
from pathlib import Path
import json, subprocess, uuid
files = sorted(Path('/var/tmp').glob('mtt-s30-test-*.json'))
if not files:
    raise SystemExit('没有公共测试摘要；先核对路径。')
path = files[-1]
data = json.loads(path.read_text())
print('摘要:', path)
print('profile:', data.get('profile'), 'phase:', data.get('phase'))
print('test boot:', data.get('boot_id'), 'logs:', data.get('logs'))
print('probe:', data.get('probe', {}).get('error'))
print('当前 boot:', Path('/proc/sys/kernel/random/boot_id').read_text().strip())
print('mtgpu loaded:', Path('/sys/module/mtgpu').exists())
subprocess.run(['uname', '-r'], check=True)
subprocess.run(['systemctl', 'is-active', 'display-manager'])
boot = uuid.UUID(data['boot_id']).hex
subprocess.run(['journalctl', '--boot='+boot, '-u', 'mtt-s30-once.service',
                '--no-pager', '-n', '120'], check=True)
PY
```

本机 journalctl 不接受带连字符的 UUID boot descriptor，必须转换为 `uuid.UUID(boot_id).hex`。不要靠 `-b -1` 长期关联现场；若用户又正常重启了一次，它就不再是测试那次启动。

### B. 定位、修复、验证

1. 明确失败在哪一层：启动/监督流程、内核初始化、合成器、客户端、退出清理、恢复核验。写出已执行、失败、未执行三类。
2. 保留原失败日志、core 与原制品。当前没有 Git，覆盖前必须有可核验副本。不要清理旧 work/builds/root 测试目录来节省空间。
3. 按实际加载文件、ABI、调用栈提出可证伪原因，修复最小必要范围。不要从一次错误直接改整个图形栈或取消断言、内核缓解机制。
4. 让本地测试复现真实反例；验证修复后的实际最终库，而不只测试源码里复制出来的函数。注明 stub/模拟、CPU 对照和真实设备的区别。
5. 构建到新目录，保留旧候选。检查来源 SHA、原指令、最终文件、运行依赖、库路径、版本及所需测试；二进制/ABI 变更需有可复现构建和明确 manifest。
6. 修改候选时同步审阅 `PROFILE`、`BUNDLE_DIRECTORY`、`MANIFEST_SHA`、builder 中的 profile/来源、测试和说明。更新哈希是修复验证的结果，不能成为绕过错误的方法。
7. 当前流程回归命令为：

```bash
python3 -m unittest discover -s maintenance/recovery -p 'test_*.py'
```

v12 准备时为 107 项通过，其中包含真实进程树清理；该数值是历史记录，后续测试增减后以实际输出为准。内核、ABI、析构及 KWin 格式测试应按受影响组件选取，命令及证据在对应报告和 `maintenance/desktop/test-*.py`，不要为无关文档修改重复实机测试。

### C. 软件对照与重新构建示例

以下是复现已有 v12 的工具入口，**不是 Plasma 当前崩溃已经修好的证明**。输出目录必须不存在；软件对照用普通用户执行，要求 mtgpu 未加载，stage 路径要短，UNIX socket 不能达到 108 字节。

```bash
python3 maintenance/desktop/build-plasma-checks.py \
  --kwin-work work/p12-kwin-session-build \
  --output work/NEW-v12-rebuild

python3 maintenance/desktop/validate-userland.py \
  --bundle builds/desktop-plasma-v12-20261109 \
  --stage work/NEW-cpu \
  --software-root work/userland-fix-20261031/ubuntu-mesa
```

软件对照启动独立虚拟 KWin、Plasma 和 XWayland，不接入当前用户桌面。它明确使用 CPU，不能通过 S30 验收门槛。需要改动 KWin 时再使用 `build-kwin-session-compat.py`，先读其原树核验/备份/恢复逻辑，不要重新选择一个名字相似的旧构建树。

### D. 准备实机窗口

只有具体修复、候选与本地验证准备好后，才给用户明确的下一轮命令。当前 v12 原样失败，应先诊断。之后保存工作并在用户自己的终端运行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --desktop
```

该入口自动创建新 EFI/root 备份、审计默认启动项和 initramfs、核验固定制品与版本、校准 watchdog，再退出 KDE，临时加载驱动并安排重启。禁止复用旧 root 目录直接 `test-once.py start <旧时间>`；README 历史部分的旧命令不是当前重试命令。

常规读取、修复和可逆本地验证不需反复请求许可。退出桌面、硬件加载或重启必须落在用户已安排的具体测试窗口；“默认继续适配”不意味着随时中断用户工作。

### E. 导出后验收并记账

复核图像末帧、完整视频、真实设备身份和实际加载库；逐帧统计依据固定版本程序及完整日志，不把末帧比较写成独立捕获了所有帧。核对呈现反馈、完整销毁、进程退出和退出后 KWin 状态。内核日志限定到模块加载之后，区分停止原桌面时已有的其他进程崩溃。

每轮写明：测试 ID、内核/profile、manifest 与源 SHA、达到阶段、错误/调用栈、修改、验证结果、恢复结果、仍未验证范围、下一动作。把“最新尝试”和“最后完整通过”分开。历史准备文档保留当时状态，当前入口用新说明指向最新结果。

## 6. 不得破坏的恢复约束

- 不在现有 KDE 会话中直接 insmod；受控流程必须等待显示管理器、合成器和 DRM 使用者退出，并连续两次确认空闲。不要跳过不满足的加载门槛。
- 目前只临时加载。不要执行厂商安装脚本、安装 DKMS 包、配置开机模块、改 initramfs/启动项、替换系统 KWin/EGL、写全局图形环境或关闭内核缓解机制。持久安装是后续独立部署任务。
- 每轮新建基线。EFI 加载前要求全文件一致；重启后只允许 `loader/random-seed` 正常轮换，其他增删改必须解释。不能将“桌面正常回来”当作 EFI 全量核验通过。
- 系统升级可能替换内核/initramfs，使旧 EFI 基线失效。保留旧结果；用 `inspect-next-boot.py` 检查新的默认启动文件和无 mtgpu 的正常/备用 initramfs，正常重启新内核后重新建基线，不直接放宽比较。
- v12 私有桌面阶段总限时 100 秒，整组 TERM/KILL 收尾另最多约 4 秒。前面的停桌面、加载、Vulkan/视频/GBM 不计入这 100 秒。监督器仍于约 180 秒请求正常重启，独立后备为 210 秒，慢测试可能被提前截断。不要为了得到“通过”延长恢复期限。
- 私有会话保留独立 HOME/XDG、无服务自动激活的 D-Bus、独占抽象 X socket 和随机 0600 Xauthority。不要连接用户已有总线、导入 systemd 用户环境或删除别人的 X socket。私有会话不是系统总线沙箱。
- `session_process.py` 的进程组覆盖显式 D-Bus/KWin/Plasma/Activities/KIO/XWayland。KWin 输出缩放变化仍有 detached helper 例外；本轮不测缩放/热插拔，扩展到该范围前须先处理。硬件测试还有服务 cgroup 与重启监督。
- watchdog 已验证 SP5100 的 60→57→60 倒计时、喂狗和启停，**从未证明硬件超时复位**。不能保证任意内核挂死都自动恢复。必要时用户需在本机手动重启；不要说“三分钟保证恢复桌面”。
- 原有人工恢复步骤：先等计划重启；机器仍响应时用文本控制台请求正常 reboot。约十分钟仍无进展且控制台也无响应时需本机强制关机后启动原项；启动项异常则保留错误并使用救援介质检查，不能盲目覆盖 ESP。
- 不靠 rmmod 试图现场恢复 simpledrm。日志导出严格限制本轮 boot/unit/UID/EXE/PID/信号和文件大小权限，不导出认证 cookie、私有总线配置或泛化 root core。

## 7. 排错经验：哪些捷径曾经误导我们

1. **构建、加载、枚举、渲染、呈现、销毁、长期运行是不同阶段。** v9 已画完 60 帧但销毁 SIGABRT，仍是失败；v12 基础负载通过也不代表 Plasma 可用。
2. **同版本字符串不等于同一私有 ABI。** screen/context/config/display 的布局和所有权都曾分别出错。优先公开回调；必须桥接时限于准确厂商/平台/架构/文件版本，保留拒绝路径和销毁期生命周期。
3. **EGL 成功不等于 GL 分发正确。** `eglMakeCurrent` 成功后仍可能使用另一套线程分发表；必须记录 renderer、vendor、实际库路径与线程上下文。Plasma 桌面 OpenGL 不能从 Qt GLES 通过直接推导。
4. **查询广告能力不等于实际可用。** v7 context-current 重查没有移除真实不可导入格式；回归要包含硬件实际的 22→8 格式结果、次级分支与拒绝反例，不能只给有利模拟输入。
5. **软件会话也会出现“硬件呈现”标志。** 必须同时核对 S30 renderer、render node、PCI/模块绑定和实际 DRI 库。CPU 软件通过仅证明测试流程/协议部分。
6. **使用实际二进制复现反例。** 析构修复有原库 ASan 失败、修复库同样输入正常且逐项核对释放；只绕过 free 或成功退出不足以证明所有权正确。
7. **core 不仅按 GNU build ID 匹配。** v10 修复副本保留原 build ID；必须按本轮 manifest 路径和完整 SHA256 找库。SIGABRT 返回地址还要核对调用指令及 PC−1，避免落到后一个函数误判。
8. **不能笼统说“闭源文件都没改”。** 闭源内核核心未改；客户端专用主 DRI 已修改两条指令。原包和次级 DRI 保留原样，KWin/GBM 与 Wayland 客户端的库路径刻意不同。
9. **WARN_ONCE 会隐藏后续同类错误。** 修一个栈之后检查全部相关调用点，不能靠警告消失判断全面修复。日志里实际无新故障，只能按筛查范围陈述。
10. **成功记录必须晚于清理。** Qt 曾在应用析构前写成功；另一次 readback 已完成但最后交换还没完成。现在等待交换并完成应用清理后记录，保持原有超时，不能靠额外一帧像素或隐藏失败放宽标准。
11. **恢复失败也要定位，不能统一归咎显卡。** 随机种子轮换、boot ID 格式、升级后的启动文件都曾影响报告；识别允许差异和基线变化，同时保留真实异常。
12. **旧文档和聊天会过时。** 本次交接正是通过新摘要发现 v12 已跑过。开工先查现场；只读到摘要就写“摘要显示”，读到 core/完整数据后再提升结论。

## 8. 尚未完成，以及 Arch/AUR 的边界

当前不能宣称适配全部完成或适合日常长期使用。尚待完成：Plasma 当前 SIGSEGV、XWayland 硬件 GLX/DRI3、完整登录服务/锁屏/电源/音频/portal、缩放/多屏/热插拔、长期稳定与资源增长、休眠唤醒、其他视频格式/编码/计算，以及 LTS 实机运行。

闭源内核核心每次构建仍有 5,486 条 objtool 告警，内核缓解机制和其他 CPU 的兼容性未获保证。原库与析构修复库在加载/卸载对照中都残留 22 项、74,268 字节分配，持续运行影响未测。不能隐藏告警或扩大到其他机器/内核范围。

`mtgpu-s30-dkms 3.1.0-2` 目前仅完成本地 makepkg 和私有 DKMS add/build。它包含内核源码与固件，**没有完整 EGL/GLES、Vulkan、VA-API 用户态及 KWin/Wayland 修复**；未验证系统安装/卸载 hooks、内核升级、持久启动及回退。即便包没有 modules-load 文件，安装后 DKMS hook/PCI alias 也可能导致开机加载，与临时测试不同。

用户仅表示考虑上传 Arch/AUR，尚未授权发布。发布前需要核对完整用户态部署、已有 AUR 包与维护范围、源码/补丁和闭源组件的公开授权。`maintenance/arch/README.md` 的包状态和 AUR 查询是当时快照，公开前重新查官方规则与现有包。不要从模块 `Dual MIT/GPL` 推导厂商固件、预编译核心和所有用户态均可再分发；不要上传 deb、固件、二进制包、core、机器日志或整个测试树。

迁移助手不等于公开发布或换机器。本地继续工作的 Gemini 应直接使用现有目录。若只使用无法访问本机的聊天界面，先给本文和经过筛选的文本日志，实际命令仍由用户本机执行；不要把厂商二进制和 root 现场整包上传。

## 9. 与用户协作的约定

- 默认中文。先说当前真实结论，再说明证据、修改及下一步；区分已验证、推断和未知。
- 用户希望直接推进修复，不要反复问“要继续吗”。同时保留测试窗口与启动恢复约束，不擅自中断当前桌面。
- 优先深化当前故障的证据与修复，不无故扩展功能；只改相关内容，保留既有目录、报告风格和历史证据。
- 需要 sudo 时，把准确命令和为什么需要本人执行一起给出；从不索要密码，不改 sudoers 来绕过。
- 修好后给出具体候选、测试结果和下一轮操作。失败后记录确切阶段，不能以“驱动不兼容”一句话结束，也不能以编译成功宣布完成。
- 新助手应自己复核当前文件与事实。本文的约定来自用户要求和已采用的流程，不依赖某个特定模型或客户端。

## 10. 可复制给 Gemini 的开场指令

```text
请接手本机 MTT S30 / Arch 驱动适配。
工程：/home/bull/Documents/mtt-s30-arch
先完整阅读 maintenance/GEMINI-HANDOFF-20261109.md，并核对最新公共摘要。

当前最后完整通过的是 v11（20261109-160826）。v12 已于
20261109-170542 实机运行：基础负载、五轮原生 Wayland 和 Qt Quick
通过，随后测试会话 plasmashell SIGSEGV，栈在
QWaylandGLContext::makeCurrent，XWayland 应用验收尚未到达。
机器已回到 KDE，但本轮 root 日志/core 和 EFI 恢复尚未导出核验。
不要重复原样 v12，不要安装驱动，也不要发布 AUR。

先分析现有可读日志，再请我在本机运行该轮 collect-results.py
只读导出，继续定位 Plasma 的实际根因。始终保持临时加载、每轮新
EFI 基线、版本/制品校验、独立恢复监督；不能改启动项、initramfs
或系统图形库来抢先测试。软件成功不算 S30 验收通过。

以后我说“重启完成”，默认读取该轮日志、核验恢复并继续适配，
无需再问是否继续。sudo 密码由我本机输入；准备新的硬件测试时
先完成具体修复和本地验证，再给我明确的受控入口与保存工作提示。
```
