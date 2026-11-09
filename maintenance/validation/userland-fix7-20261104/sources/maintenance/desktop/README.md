# EGL/GBM 和 Wayland 测试程序

**2026-11-04 当前候选：`kwin-wayland-v8` / `desktop-userland-fix7-20261104`。** v7 实机否定“current 后查询即可排除 XB24”的假设：厂商次级 context 不设置 primary TLS。v8 将集合再与固定 3.1.0 真实导入表取交集，同时排除 XB24/AB30，保留所有错误检查。35 项实际源码/库回归、旧 v7 反例、64 项流程和 60 帧联合软件验证通过；S30 窗口仍待实测。见 [当前记录](../runtime-findings-20261104-200750.md)。

`egl-check.c` 绘制动态色块并逐像素核对。`gbm` 模式必须打开 mtgpu render 节点；`wayland` 模式连接当前进程指定的独立会话，两者均要求 S30 renderer。软件验证模式仅用于测试程序自检，不能通过硬件结果判定。

仅构建 EGL 测试程序时，在工程根目录输出到新的目录：

```bash
python3 maintenance/desktop/build.py --output builds/my-desktop-test
```

需要本机 EGL/GLES3、GBM、libdrm、Wayland 开发头和 wayland-scanner，协议 XML 使用 Qt 安装目录。构建不会打开 GPU。每次源码或协议改变后必须重新构建、自检并审阅更新恢复模块中的 manifest 哈希；不覆盖已审阅的制品。

历史基础制品为 `builds/desktop-userland-fix1-v2-20261031`，profile `kwin-wayland-v2`。它增加私有 KWin、同版本 EGL/glapi，并保留错误阶段区分和实际库路径记录。历史构建使用 `build-userland.py`；联合软件验证使用 `validate-userland.py`。构建与测试命令、源包校验及恢复边界见 [第七轮说明](../runtime-userland-fix1-20261031.md)。这些旧制品保留，不用于当前实机重试。
