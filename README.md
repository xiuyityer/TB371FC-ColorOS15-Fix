# 卡鱼 coloros15 综合修复 v1.0

作者：**xiuyityer**　|　KernelSU 模块 ID：`kayu_coloros15_fix`

下载：[GitHub Release v1.0](https://github.com/xiuyityer/TB371FC-ColorOS15-Fix/releases/tag/v1.0)。选择 `kayu-coloros15-fix-v1.0.zip`，不要安装 GitHub 自动生成的源码压缩包。

适用范围：联想 TB371FC (`spinel`)，第三方 ColorOS `OPD2413_15.0.1.801(CN01)`，A 槽，`4.19.325-perf++ #789` + KernelSU，SELinux `Enforcing`。安装和开机都核对对应属性；早期与运行时脚本还核对输入文件。本包不包含 boot、ROM 镜像或底层固件，不安装 KernelSU 本身。不为其他 ROM、槽位、硬件或相同版本号的不同移植包提供兼容保证。

| 功能 | 使用的已验收独立版本 |
| --- | --- |
| 通信共享联网 | 声明 v1.2 + provider v0.5 |
| 跨屏镜像 | 投屏 v0.1，修复加载和窗口裁切 |
| 刷新率 | 刷新率 v0.1，全局高档 144 Hz，检测到笔降到 120 Hz，离开恢复 |
| 原生手写笔 | Tab Pen Plus v0.3，原生连接、充电和版本读取、短按切换便签工具、长按区域截屏 |

通信共享首次建链测试时需亮屏；没有验收息屏新建链路、语音或短信。笔电量通知已订阅，未单独观察到同一连接内跨百分比变化。「随手写」不在修复范围内；笔 OTA 仍由候选禁用。

## 安装与回退

1. 保留原模块和恢复路径。笔移离屏幕，等刷新率恢复高档。KernelSU Manager 中**停用而不卸载**下列旧模块，确认没有它们的待生效更新：`c15_sharing_subscription_test`、`c15_sharing_provider_test`、`c15_mirroring_test`、`c15_refresh_pen`、`c15_native_pen`。停用开关不等于已撤销本次开机的挂载。
2. 在 Android 的 KernelSU Manager 内安装 `kayu-coloros15-fix-v1.0.zip`，然后正常重启一次。不要从 Recovery 刷此 ZIP，也不要与旧模块同时启用。不用刷分区或清数据。
3. 检查 `/data/adb/modules/kayu_coloros15_fix/early.log`、`late.log` 和 `components/*/` 内的日志，再实际测试共享联网、投屏、笔感应刷新率和原生手写笔。启动入口日志只证明脚本执行，不代替进程读回与功能测试。

退回独立版：停用 `kayu_coloros15_fix`，重新启用原五个模块；如果已经卸载，从原 ZIP 重装，再正常重启。退回无修复状态：新旧模块全部停用后重启。若异常中断留下 `/data/adb/c15-refresh-pen/checkpoint`，不要直接删；保留 `pen-refresh`，待笔服务停止时用该程序的 `--restore MODULE_DIR STATE_DIR` 恢复原设置。完整停用笔适配后，如原生页保留过期状态，可以清理模块留下的 `ipe_pencil_connect_state` 和 `ipe_pencil_charging_state` 全局值，不必解除配对。

## 本地构建

需要 Python 3.9+。`inputs.lock.json` 固定五个已验收模块 ZIP 的 SHA-256。将合法持有的本地输入按清单名放入 `inputs/`，或用 `--inputs` 指向原工作区的 `worklog/runs`。批量打包器不会联网下载依赖。

```sh
python3 build.py --inputs /path/to/local-inputs
python3 tests/check.py dist/kayu-coloros15-fix-v1.0.zip --inputs /path/to/local-inputs
```

Release 模块 ZIP 含 ROM 派生载荷和供体库；这些文件不提交到 Git 源码树。从原件复现修复见 [补丁与原理](methods/README.md)。整合打包器使用固定的独立 ZIP，补丁脚本不是一键生成所有依赖的 ROM 构建器。

## 当前验收状态

2026-11-20，TB371FC 卸载旧五模块后安装 v1.0，正常重启并自动加载。用户确认四项功能均正常。通信共享实际走 `ovnet0` 通网；平板读回 144 Hz，系统笔页面显示已连接。详见 [验收记录](TESTING.md)。

## 许可

项目原创源码按 [GPL-3.0-or-later](LICENSE) 发布。`methods/sharing/vnet/` 保留上游内核驱动的版权和许可，见 [第三方说明](NOTICE.md)。开源许可不覆盖厂商 ROM、APK、JAR 和共享库。
