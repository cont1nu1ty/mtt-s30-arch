# MTT S30 第三次测试：部分修复已实测，仍有三项阻断

测试目录 `20261029-231534`，内核 7.2.11-arch1-1，加载模块 SHA256 `824b81aa1a2cae0714bf670b78cf0a29ceaac87f6ac395281a3acb44fb530a0c`。23:16:20–22 初始化；23:18:47 监督服务请求正常重启。当前 KDE 已恢复，mtgpu 未随开机加载。

## 本轮实测结论

| 检查 | 结果 |
| --- | --- |
| 模块加载、PCI 绑定、renderD128 | 通过；insmod=0，耗时 1.518 秒 |
| 提前移交启动 framebuffer | 生效；新日志不再出现 BOOTFB 冲突或 memtype_reserve_io WARNING；控制台移交先于 vendor probe |
| IPC 工作队列 | 原 mtgpu_ipc_con_workq 告警消失 |
| 另一处 PVR 工作队列 | mtgpu-wq 仍缺队列类型；调用栈 PVRSRVDriverInit+0x9d，这是上轮遗漏的直接 alloc_workqueue 调用 |
| 显示控制器 | DISPC-2 dispc_stop 仍超时，之后 HDMI 1080p 配置完成；不能把后者当作前者无害的证明 |
| VPU 资源映射 | 仍跨入显示控制器的一页寄存器，内核报 resource sanity check / mapping multiple BARs |
| 管理工具 / Vulkan / VA-API | 因初始化日志异常全部未执行 |
| 启动恢复 | 管理员核验 True；11 个 ESP 文件中 10 个不变，仅 loader/random-seed 轮换，无增删 |

本轮是计划正常重启。watchdog 倒计时和喂狗通过，不代表已经实测硬件超时复位。

## 本轮已完成的源码修复

`src/pvr/module_common.c` 的 `alloc_workqueue("mtgpu-wq", 0, 0)` 经过上一轮的兼容函数补齐 PERCPU 默认。同步覆盖 osfunc.c 的两个优化分支调用，避免同类遗漏。新覆盖检查扫描 src 下全部 6 个直接 alloc_workqueue 调用点，要求经过兼容层；真实 PVRSRVDriverInit 的测试同时验证旧/新内核语义、分配失败和前置初始化失败传播。

10 项回归测试通过（真实 C 函数编译，ASan/UBSan）；新模块在 7.2.11 和 6.18.58 上都从官方包干净重建成功。最终模块反汇编确认 PVRSRVDriverInit 传入 WQ_PERCPU=0x100。厂商 blob 未改，两个构建各仍有 5486 条 objtool 告警。

新 7.2.11 模块：`builds/runtime-fix2-7.2.11-20261029/source/mtgpu.ko`，SHA256 `51bfdcb07ea34a62e4a2fed2ea336b02820991ce0721218dfdee4652ef9f1506`。
新 LTS 模块：`builds/runtime-fix2-6.18.58-20261029/source/mtgpu.ko`，SHA256 `3b530b3228fee7436d963ef6edda1350322590f71aaeb9cdb8b06bad0059add3`。
二者均尚未加载实测。LTS 内核未安装。

内核对此类队列使用 WARN_ONCE；每轮只会暴露最早触发它的队列，因此第一轮 IPC 告警掩盖了后面的 mtgpu-wq。上轮未全量检查直接调用是覆盖遗漏，现已补上；不能据一条告警消失就推断全部队列修复。

## 尚未完成的两项修复

### DISPC 停止超时

源码在 ctx_init 后调用 core->deinit，之后才 mtgpu_enable_interrupt。SUDI 的函数表确实指向 db9000 核心：deinit 调用 stop；stop 清除显示使能，等待约 500 ms，条件是 ctx.disable_done；ISR 在相应中断状态下设置此标志并唤醒等待队列。本轮日志中止超时也确实发生在启用 dispc:58 中断之前。

这条证据链支持初始化中断时序问题。但现有 ISR 会把 VSYNC 交给尚未构建好的 CRTC，drm_vblank_init 更晚才执行；原代码注释明确提到提前中断可能造成 Oops。可行修复需要把初始硬件完成通知与 DRM 就绪后的 vblank 通知分开，并完善错误退出时的中断撤销/同步，不能仅把 enable_interrupt 提前或伪造 disable_done。此修复尚未实施。

### VPU 映射范围

本轮 /proc/iomem 证实 BAR0 为 ea000000–ebffffff，其中 dispc-regs 分别占 ea116000–ea116fff、ea117000–ea117fff、ea118000–ea118fff。
VPU 按闭源 SUDI 配置映射 ea108000–ea116fff，末尾 4 KiB 与第一个 dispc-regs 重叠。这是同一 BAR 内的子资源范围冲突，不应按日志措辞理解为真的跨越两个 PCI BAR。

静态配置给出 base 0x108000、size 0xf000、3×0x4000 core、top offset 0xd000。扫描直接访问 mt_chip.vaddr 字段的指令，目前找到三个函数，其直接 top 访问落在已知 top 页内；这个扫描不能证明不存在通过别名或动态偏移的其他访问，尚不足以安全断言裁掉最后一页即可。没有缩短映射、修改资源标志或忽略告警。

## 当前交付边界

本轮检查与工作队列补丁完成；完整驱动适配未完成。仍保留严格停止条件，尚未验证图形/视频用户态。
新候选模块未切换到 prepare-and-test.py；该入口仍锁定本轮已经测过的 824b81aa… 模块。先完成剩余两项修复及错误路径检查，再固定下一轮模块哈希，避免重复相同测试。当前无需再次运行旧命令或重启。

原始日志：`/var/tmp/mtt-s30-results-20261029-231534`。
同目录的 `mtt-s30-third-run-analysis.json` 保存结构化结论；`mtt-s30-runtime-fix2-20261029.tar.gz` 包含完整补丁、测试、构建结果及相关证据，不包含厂商二进制。
