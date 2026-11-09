# MTT S30 真实渲染与 H.264 硬解测试

实测更新：2026-10-30 的 `20261030-084900` 已通过以下全部负载及恢复核验，导出的原始像素和视频数据再次复核一致。详见 [第五轮实测结果](runtime-findings-20261030-084900.md)。下文保留该轮测试的准备与复现方法。

准备日期：2026-10-30。沿用已通过第四轮初始化/接口枚举的内核模块 `db8e4393ec50e0e2542dafdb7277240627406b847dc19d0427444712249143bb`，本轮没有重新修改内核驱动。

## 本轮执行内容

1. 重做备份/启动项核验、watchdog 校准、桌面退出等待，临时加载后先验证管理工具、Vulkan、VA-API 和内核日志。
2. **真实 Vulkan 绘制**：仅选择 PCI `1ed5:0102` 的离散 GPU。通过图形管线、顶点/片元着色器和 `vkCmdDraw` 绘制 128×96 图像，共 8 帧；每帧改变颜色排列，读回全部像素与 CPU 预期逐字节比较，共 98,304 个像素。保存最后一帧原始 RGBA，并由 Python 再核对。
3. **真实 H.264 硬解**：320×192、24 fps、48 帧 High Profile 测试流，含 P/B 帧。FFmpeg C API 强制选择 VAAPI，拒绝软件像素格式回退；每一帧必须是 VAAPI 硬件帧，下载为 NV12，与事先保存的 CPU 解码参考逐字节比较。必须 48/48 帧一致，保存完整解码输出和差异统计。
4. 每项负载之后扫描内核日志。命令失败、输出不符、超时或内核异常都会停止后续 GPU 调用。仍按原监督流程重启。

本轮是短时正确性测试，尚不覆盖实际游戏、持续性能、全部视频格式、视频编码或加速 KDE。渲染与硬解通过后再安排隔离的 KDE/Wayland 验证，不直接替换当前桌面环境。

## 已完成的测试程序验证

- 两个 C 工具以 `-Wall -Wextra -Werror` 编译；SPIR-V 通过 Vulkan 1.0 目标校验。
- 在单独解包的 Mesa lavapipe 上执行完整绘制/读回，8 帧均匹配；Khronos validation layer 和 synchronization validation 无错误/告警。
- 将片元颜色故意减半，程序返回失败并定位首个错误像素。
- S30 模式在只有软件 Vulkan 设备时明确拒绝运行。
- 视频工具在软件自检模式下解码的 48 帧与参考一致；参考数据只破坏一个字节即返回失败，并准确报告一个字节差异。
- 指定不存在的 VAAPI 设备时失败，没有回退为 CPU 解码。
- 30 项恢复/工作负载流程测试通过：包括制品校验、复制后复核、软硬件模式区分、帧数、文件长度、单字节损坏以及错误后停止后续调用。原有启动恢复测试保留。
- 在厂商私有库查找环境中检查动态依赖并运行 CPU 解码自检，通过；没有在当前桌面加载 GPU 驱动。

软件参考运行只验证测试程序，**不能记作 S30 硬件负载通过**。参考运行使用的 vulkan-swrast 26.2.5、validation-layers 1.4.363.0 来自 Arch 官方归档，签名经 pacman-key 验证，仅解包到工程目录，没有安装到系统或供本轮 S30 测试选择。

程序实现参考 [Khronos 同步说明](https://docs.vulkan.org/guide/latest/synchronization_examples.html) 和 [FFmpeg 官方硬件解码示例](https://github.com/FFmpeg/FFmpeg/blob/master/doc/examples/hw_decode.c)。本机实际执行记录位于 `maintenance/validation/workloads-20261030/`。

## 启动本轮测试

保存全部工作后，在自己的终端运行：

```bash
sudo python3 /home/bull/Documents/mtt-s30-arch/maintenance/recovery/prepare-and-test.py --start --workloads
```

必须带 `--workloads`；不带它的旧命令只执行初始化和接口枚举。

当前执行器仍无免密 sudo，密码由用户在自己的终端输入。入口使用新建的 root 专属备份目录，固定内核模块哈希以及工作负载 manifest `68c2d8c057dae856de6f5baad1771125fd2310647b02098ad92b1586e5766ea8`，对复制后的所有制品再次核验。脚本、可执行文件和数据均暂存在 root 专属目录。

检查通过后退出 KDE；监督阶段约 3 分钟请求重启。单个负载命令上限 30 秒，GPU fence 单次等待上限 10 秒；保留原 60 秒硬件 watchdog 喂狗和 210 秒备用重启计时器。前置核验失败不会加载驱动；加载后任何失败仍走重启恢复。不会安装开机加载模块，不修改内核/initramfs/启动项，ESP 在加载前挂为只读。硬件 watchdog 到期复位尚未单独证明，继续保持原有恢复边界。

本轮公开摘要将带 `profile: render-decode-v1`。成功阶段为 `workload_checks_passed`，并记录 `workloads.render` 和 `workloads.video`；不能把旧的 `initialization_checks_passed` 当作这一轮通过。

重启后使用原 `collect-results.py` 导出新目录，它已支持渲染输出、解码输出及两项负载日志。旧测试与模块均保留。
