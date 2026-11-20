# 卡鱼 coloros15 综合修复 v1.0

作者：**xiuyityer**　|　KernelSU 模块 ID：`kayu_coloros15_fix`

下载：[GitHub Release v1.0](https://github.com/xiuyityer/TB371FC-ColorOS15-Fix/releases/tag/v1.0)。选择 `kayu-coloros15-fix-v1.0.zip`，不要安装 GitHub 自动生成的源码压缩包。

适用范围：联想 TB371FC (`spinel`)，第三方 ColorOS `OPD2413_15.0.1.801(CN01)`，A 槽，`4.19.325-perf++ #789` + KernelSU，SELinux `Enforcing`。安装和开机都核对对应属性；早期与运行时脚本还核对输入文件。本包不包含 boot、ROM 镜像或底层固件，不安装 KernelSU 本身。不为其他 ROM、槽位、硬件或相同版本号的不同移植包提供兼容保证。

| 功能 | 修复内容 |
| --- | --- |
| 通信共享联网 | 支持通过已连接的手机共享数据网络 |
| 跨屏镜像 | 修复投屏卡加载和窗口裁切 |
| 刷新率 | 全局高档 144 Hz，检测到笔降到 120 Hz，离开后恢复 |
| 原生手写笔 | Tab Pen Plus 连接、充电和版本读取、短按切换便签工具、长按区域截屏 |

通信共享首次建链测试时需亮屏；没有验收息屏新建链路、语音或短信。笔电量通知已订阅，未单独观察到同一连接内跨百分比变化。「随手写」不在修复范围内；笔 OTA 仍由候选禁用。

## 安装与回退

在 Android 的 KernelSU Manager 中安装 `kayu-coloros15-fix-v1.0.zip`，然后正常重启。**无需另装任何配套模块**，也不用进 Recovery、刷分区或清数据。

需要回退时，在 KernelSU Manager 停用「卡鱼 coloros15 综合修复」并重启。排查启动问题可查看 `/data/adb/modules/kayu_coloros15_fix/` 下的 `early.log`、`late.log` 和 `components/` 内的日志。

## 本地构建

此节仅用于开发。直接安装 Release 不需要构建。打包器需要 Python 3.9+，使用 `inputs.lock.json` 固定的内部测试产物。将本地输入按清单名放入 `inputs/`，或用 `--inputs` 指向原工作区的 `worklog/runs`。打包器不会联网下载依赖。

```sh
python3 build.py --inputs /path/to/local-inputs
python3 tests/check.py dist/kayu-coloros15-fix-v1.0.zip --inputs /path/to/local-inputs
```

Release 模块 ZIP 含 ROM 派生载荷和供体库；这些文件不提交到 Git 源码树。从原件复现修复见 [补丁与原理](methods/README.md)。整合打包器使用固定的独立 ZIP，补丁脚本不是一键生成所有依赖的 ROM 构建器。

## 当前验收状态

2026-11-20，TB371FC 安装 v1.0 后正常重启并自动加载，四项功能已通过实机验证。通信共享实际走 `ovnet0` 通网；平板读回 144 Hz，系统笔页面显示已连接。详见 [验收记录](TESTING.md)。

## 许可

项目原创源码按 [GPL-3.0-or-later](LICENSE) 发布。`methods/sharing/vnet/` 保留上游内核驱动的版权和许可，见 [第三方说明](NOTICE.md)。开源许可不覆盖厂商 ROM、APK、JAR 和共享库。
