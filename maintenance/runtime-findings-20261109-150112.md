# 11 月 9 日 v9 实机呈现 60 帧，窗口销毁时重复释放内存

`20261109-150112` 在 `7.2.14-arch1-1` 上运行了 `kwin-wayland-v9`。S30 首次完成本项目原生 Wayland 窗口的全部 60 帧渲染与硬件呈现。最后一帧保存后，客户端在 `eglDestroySurface` 中收到 SIGABRT。桌面会话验收仍为失败。计划重启及本轮 EFI 恢复校验均通过。[独立核验记录](validation/runtime-20261109-150112/analysis.json)

## 原生 Wayland 客户端

客户端 EGL 厂商为 Mesa Project。启用此次修复的私有 EGL 后，日志记录了本轮暂存目录下的 `libglapi_musa.so.0.0.0`，随后返回 `GL_VENDOR=MOORE THREADS`、`GL_RENDERER=MTT S30` 及 OpenGL ES 3.2。此前 v8 在这两个身份查询处退出。此次 KWin 和客户端均使用 S30。客户端创建了三个 256×192 的 AR24 DMA-BUF，KWin 为 HDMI-A-1 选择了 1920×1080 的 XR24 输出，`importMode` 和 `bufferTarget` 均为 0。[客户端日志](validation/runtime-20261109-150112/wayland-client.log) · [KWin 记录](validation/runtime-20261109-150112/desktop-session-result.json)

从协议日志逐项配对同一窗口的 60 次呈现请求与回调，时间戳严格递增。60 次回调的标志均为 7，包含垂直同步、硬件时钟和硬件完成，丢弃 0 帧。测试程序每帧逐像素校验后才发出该帧的呈现请求，因此上述 60 次请求也确认程序完成了 2,949,120 次像素比较。导出包含最后一帧的 49,152 个 RGBA8 像素，已按第 59 号帧的测试图案独立逐字节复核。这份像素证据取自客户端帧缓冲。[绘制与回读源码](desktop/egl-check.c#L183) · [末帧像素](validation/runtime-20261109-150112/wayland.rgba)

## 崩溃位置

客户端保存末帧、删除 GL 对象并成功解绑 EGL 上下文后，在 `egl-check.c:209` 调用 `eglDestroySurface`。对本轮导出的 core 使用同一版本的私有 EGL、测试程序及厂商 DRI 库回溯，调用链进入 `dri2_wl_destroy_surface` 第 840 行的 `core->destroyDrawable`，经过 `mtgpu_dri.so` 后由 glibc 报出 `free(): double free detected in tcache 2`。客户端进程 1179576 收到 SIGABRT，未完成上下文销毁、Wayland 连接清理或写出成功结果。KWin 按测试程序发送的 SIGTERM 退出，未触发强制终止，合成器故障筛查为空。[调用栈](validation/runtime-20261109-150112/client-backtrace.log) · [客户端原始日志](validation/runtime-20261109-150112/wayland-client.log)

## 基础负载与启动恢复

临时模块绑定 PCI 设备 `0000:04:00.0`，创建 `renderD128`。Vulkan 通过 8 帧、98,304 个像素的检查。EGL/GBM 通过 8 帧、393,216 个像素的检查。两条渲染路径保存的最后一帧已独立复核。H.264 使用 VA-API 解码 48 帧，导出的全部 4,423,680 字节与 CPU 参考一致。模块加载至关机的日志未命中既定内核故障筛查项。15:02:06 有一条驱动回收已崩溃客户端内存上下文的记录。[负载结果](validation/runtime-20261109-150112/workload-result.json) · [内核日志](validation/runtime-20261109-150112/journal-kernel-postload.log)

15:04:25 临时测试服务发起计划重启。当前启动时间为 15:05:04，内核及 EFI 中当前选中的启动项均与本轮备份匹配。EFI 的 11 个文件中，10 个内容一致，仅 `loader/random-seed` 正常轮换。显示管理器及 KWin 已恢复，当前内核未加载 mtgpu，模块查询未发现安装项，临时测试服务和计时器均 inactive。硬件 watchdog 已回到 inactive，本次只验证了其计数和喂狗，超时复位仍待实测。完整 Plasma、XWayland 与长时间稳定性仍待验证。[重启请求](validation/runtime-20261109-150112/journal-reboot-request.log) · [恢复核验](validation/runtime-20261109-150112/recovery-result.json) · [43 项证据校验清单](validation/runtime-20261109-150112/evidence-sha256.json)

## v10 窗口销毁修复

崩溃文件保留了原生平台类型 4 和 Wayland 平台指针。结合实际使用的 drawable 创建入口，可以还原出对象的类型为 `Ogl::Wsi::WaylandSwapChain`。该类的完整析构函数先清理派生类资源，随后对同一对象调用两次基类析构函数，第二次清理队列时命中 glibc 的重复释放检查。同一类的删除析构函数也包含这对重复调用。实机调用的是前者。两种析构入口的语义见 ABI 文档。[core 与厂商指令分析](validation/userland-fix9-20261109/core/README.md) · [C++ ABI 虚表布局](https://itanium-cxx-abi.github.io/cxx-abi/abi.html#vtable-components)

v10 在测试客户端专用的 `mtgpu_dri.so` 副本中修改了两条各 5 字节的指令，各去掉一次多余的基类调用。派生类资源、基类资源和对象存储仍各自按原所有权释放。构建程序逐项核验官方文件、两条原指令和修复后的完整文件 SHA-256。官方包、KWin 和内核模块继续使用上一轮的制品。客户端加载目录中还包含原版次级驱动 `musa_dri.so`，验收时逐个核对两个库的实际路径。两次构建的全部制品逐字节一致。修复副本保留原 GNU build ID，后续解析 core 应按对应轮次 manifest 中的路径及 SHA-256 选择文件。[构建程序](desktop/build-drawable-compat.py) · [制品清单](validation/userland-fix9-20261109/desktop-manifest.json)

离线回放调用了两份库的实际析构函数，分别测试含一个和三个数据块的对象。原库在 4 个用例中均触发 AddressSanitizer 重复释放，修复副本在 4 个相同用例中正常返回，并验证了每块内存、队列映射与对象本身的释放情况。单独进行动态库加载再卸载时，两份库均留下 22 项共 74,268 字节的分配，长期运行时的影响仍待测量。另有 4 项实际加载目录验证、68 项恢复与桌面流程回归通过。虚拟 KWin 软件对照完成 60 帧且客户端正常退出。[析构回归与卸载对照](validation/userland-fix9-20261109/lifetime/results.json) · [加载目录核验](validation/userland-fix9-20261109/routing/results.json) · [v10 本地验证及复现命令](validation/userland-fix9-20261109/validation.json)

下一轮使用新的恢复备份。通过条件包括 S30 完成 60 次硬件呈现、逐像素核对、窗口与上下文销毁成功、客户端退出码为 0、退出后 KWin 正常及启动恢复核验。保存工作后运行单次测试入口。完整 Plasma 会话和长期稳定性尚待后续实测。[受控测试命令与人工恢复方法](recovery/README.md)
