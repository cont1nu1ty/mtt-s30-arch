# S30 工作负载构建

构建工具只编译程序并生成 CPU 参考数据，不加载或访问 GPU：

```bash
python3 maintenance/workloads/build.py --output builds/workloads-NEW
```

输出目录必须是新的；不要覆盖当前已审阅的 `builds/workloads-20261030`。每次重新构建后必须重新验证程序，并更新测试入口固定的 manifest 哈希；不要跳过哈希校验。

`vk-offscreen` 正常模式只允许 S30；`--software-validation` 用于测试程序开发，要求 CPU Vulkan 设备和 Khronos 验证层。`h264-check` 正常模式要求指定 DRM render 节点并逐帧确认 VAAPI；`--software-check` 仅用于测试程序自检。这两个软件模式都不会被受控实机入口调用，工作负载结果检查也会拒绝软件模式。

运行方案及验收边界见 [真实负载测试说明](../runtime-workloads-20261030.md)。
