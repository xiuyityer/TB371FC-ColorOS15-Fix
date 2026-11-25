# 卡鱼 coloros15 综合修复

作者：**xiuyityer**　|　KernelSU 模块 ID：`kayu_coloros15_fix`

- **正式版 v1.0.2** 包含通话、短信流转修复，并为配对手机的第二张 SIM 补齐虚拟 Radio 和 IMS 服务。双卡手机的卡二来电、短信和数据仍需实卡联测。[下载模块 ZIP](https://github.com/xiuyityer/TB371FC-ColorOS15-Fix/releases/download/v1.0.2/kayu-coloros15-fix-v1.0.2.zip)
- 历史版本见 [GitHub Releases](https://github.com/xiuyityer/TB371FC-ColorOS15-Fix/releases)。

本地 v1.0.1 修复了重启后长时间停在锁屏、随后打开手写笔设置仍显示「未连接」的问题。原生笔模块会在用户首次解锁后启动笔服务。

本地 `v1.0.2-beta.1` 加入 **Lenovo Precision Pen 3** 的实验性识别。已配对并建立 HID 连接后，模块会尝试在 ColorOS 手写笔页显示连接状态。Precision Pen 3 需要持笔用户实测。配对、书写、电量、充电和笔键的验证状态见 [试测说明](TESTING.md#precision-pen-3-试测)。

本地 `v1.0.2-beta.2` 加入系统手写笔连接胶囊，并试接 Precision Pen 3 的充电胶囊。连接触发来自 HID，充电提示由笔实际报告的充电状态触发。

本地 `v1.0.2-beta.4` 在连接胶囊中显示当前手写笔上报的电量百分比，并通过原厂设备空间服务注册联想笔卡片。

已发布的 v1.0 实机验证环境为联想 TB371FC (`spinel`)、第三方 ColorOS `OPD2413_15.0.1.801(CN01)`、A 槽、`4.19.325-perf++ #789`、KernelSU 和 SELinux `Enforcing`。

v1.0.2 取消安装和开机时对机型、槽位、ROM 指纹、内核版本及 SELinux 模式的硬编码限制。各组件仍依赖对应的原始文件和系统接口，通信共享的 `oplus_vnet.ko` 仍需通过当前内核的正常加载检查。其他机型和内核尚待实机验证。ZIP 仅包含修复模块及其组件，安装需要设备已有 KernelSU。

| 功能 | 修复内容 |
| --- | --- |
| 通信共享联网 | 支持通过已连接的手机共享数据网络 |
| 通话和短信流转 | 支持在平板接听手机来电、接收手机的普通 SMS |
| 跨屏镜像 | 修复投屏卡加载和窗口裁切 |
| 刷新率 | 全局高档 144 Hz，检测到笔降到 120 Hz，离开后恢复 |
| 原生手写笔 | Tab Pen Plus 连接、充电和版本读取、短按切换便签工具、长按区域截屏 |

通信共享首次建链实测时平板亮屏，息屏新建链路尚未验收。笔电量通知已订阅，未单独观察到同一连接内跨百分比变化。「随心写」已实机测试，功能正常；笔 OTA 仍由候选禁用。

此前的 beta.8-ims 在 TB371FC 与一加 11 上验证了手机来电响铃、平板接听、普通 SMS 进入平板收件箱和通知。主动拨号与主动发短信尚未验收。[修复原理](methods/README.md#来电与短信流转) · [实机记录](TESTING.md#v102-beta8-ims-通话与短信)

## 安装与回退

在 Android 的 KernelSU Manager 中安装下载的模块 ZIP，然后正常重启。**无需另装任何配套模块**，也不用进 Recovery、刷分区或清数据。

需要回退时，在 KernelSU Manager 停用「卡鱼 coloros15 综合修复」并重启。排查启动问题可查看 `/data/adb/modules/kayu_coloros15_fix/` 下的 `early.log`、`late.log` 和 `components/` 内的日志。

## 本地构建

此节仅用于开发。直接安装 Release 不需要构建。打包器需要 Python 3.9+，使用 `inputs.lock.json` 固定的内部测试产物。将本地输入按清单名放入 `inputs/`，或用 `--inputs` 指向原工作区的 `worklog/runs`。打包器不会联网下载依赖。

```sh
python3 build.py --inputs /path/to/local-inputs
python3 tests/check.py dist/kayu-coloros15-fix-v1.0.2.zip --inputs /path/to/local-inputs
```

Release 模块 ZIP 含 ROM 派生载荷和供体库；这些文件不提交到 Git 源码树。从原件复现修复见 [补丁与原理](methods/README.md)。整合打包器使用固定的独立 ZIP，补丁脚本不是一键生成所有依赖的 ROM 构建器。

## 当前验收状态

2026-11-20，TB371FC 安装 v1.0 后正常重启并自动加载，四项功能已通过实机验证。通信共享实际走 `ovnet0` 通网；平板读回 144 Hz，系统笔页面显示已连接。详见 [验收记录](TESTING.md)。

## 许可

项目原创源码按 [GPL-3.0-or-later](LICENSE) 发布。`methods/sharing/vnet/` 保留上游内核驱动的版权和许可，见 [第三方说明](NOTICE.md)。开源许可不覆盖厂商 ROM、APK、JAR 和共享库。
