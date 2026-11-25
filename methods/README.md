# 修复方法与复现

这里保留本地编写的修复脚本和源码片段；构建需自行提供精确匹配的 ROM／供体文件。带签名的原件供系统扫描，运行时的候选 APK 不可用 `pm install` 安装。补丁脚本依赖特定二进制布局，不应跨版本强用。模板和本地构建脚本还记录了兼容性限制和各载荷校验。

## 通信共享

- `post-fs-data` 先提供订阅 feature 和 DMTP AIDL V2／`vircommslot1` 声明。亮屏首次建链仍使用原有 ColorOS 策略。
- 从 OPPO `OPD2401_15.0.0.1301(CN01)` 提取 `commcenterd`、`subsys_daemon` 以及匹配的 64 位依赖，限制在独立进程搜索路径。先注册 DMTP，再启动原 Radio；`radio-onload.c` 在已有 Looper 的初始化线程上预初始化所需对象。API 补丁在通信对象就绪后发送远端通知，并保留本地音频状态更新。
- `oplus_vnet.ko` 的[对应源文件和 Makefile](sharing/vnet/)保留上游版权信息与许可。用目标 `#789` 的 `Module.symvers`、配置和头文件构建外置驱动，Makefile 为该驱动增加 `-march=armv8.2-a+lse`。加载前核验 vermagic 和全部导入 CRC；实测为 46/46，不改写 CRC，不强载其他内核版本的驱动。
- `patch-vonr.py` 针对 C15 的 `OplusVirtualComm.apk`，保护缺省的 IMS 对象，并在接收双卡手机状态时检查 `0 <= slot < mPhoneCount`，不会把副卡重映射到主卡。

```sh
python3 sharing/patch-radio-startup.py lib-virtual-modem-api.so patched-api.so
python3 sharing/patch-ims-local.py lib-virtual-modem-qti-ims.so patched-ims.so
python3 sharing/patch-vonr.py OplusVirtualComm-stock.apk OplusVirtualComm-slot-signal-guard.apk --slot-bounds --signal-bounds
```

### 来电与短信流转

原模块能加载虚拟 SIM 和数据通道。实机上，Telecom 缺少创建通话账户所需的能力声明，Android 也因缺少 IMS 能力声明而跳过 ImsResolver。虚拟 IMS 层收到了来电状态，电话框架仍保持空闲。

- 在 `post-fs-data` 分别声明 `android.hardware.telephony.calling`、`android.hardware.telephony.messaging` 和 `android.hardware.telephony.ims`，沿用原有虚拟订阅和 DMTP 声明。对照测试中，加入通用电话声明会让同一对设备被误判为不同账号。最终版省略该声明，保留原有账号校验。
- 在 VINTF 中声明供体的 HIDL 1.7 `vendor.qti.hardware.radio.ims::IImsRadio/imsradio0`。打包时核验固定的 IMS 库哈希并还原服务注册指令，跳过注册后会崩溃的 Mindroid 日志调用，保留原有清理和栈检查。
- Android 随后为虚拟订阅绑定 `org.codeaurora.ims` 的 MMTEL。来电状态由 IMS 交给 Telecom；普通 SMS 由 IMS 进入 Android 短信处理，再通过 `SMS_DELIVER` 交给默认短信应用。[实机记录](../TESTING.md#v102-beta8-ims-通话与短信)

## 跨屏镜像

原 ODMF 解码器在 Surface 输出路径上分配 HEVC 缓冲失败；`patch-odmf.py` 改用 Surface 适配路径。`patch-padconnect-display.py` 将供体固定的 `2400 × 3392` 稳定尺寸改为实际屏幕尺寸。把 `c15-odmf.original.jar` 和 `PadConnect.original.apk` 放在对应脚本旁，分别运行两份脚本。两份候选只在主 Zygote 的挂载视图中绑定，PackageManager 继续读原件。整合版从 init 取得主 Zygote PID，避免开机期间 `pidof zygote64` 误匹配刚派生的应用进程。

## 144 Hz 与笔接近时降到 120 Hz

对 C15 原 `refresh_rate_config.xml` 应用 `refresh/refresh-rate.patch`，在 `system_server` 读取前绑定，保留 60 Hz、自动档及投屏／录屏规则。随包二进制对应 `refresh/pen-refresh.c`（C17 的笔桥 v0.4.1，源码内有 GPL 标识）。桥接读取 NVT 笔与触控事件以及 `/proc/fw_pen_state`，只有笔会话期间投 120 Hz，离开或停用后恢复保存的选择。整合版沿用 `/data/adb/c15-refresh-pen` 状态目录以恢复快照，通过总模块目录监测 `disable`／`remove`。

## Lenovo 手写笔

只在已配对的 Lenovo Tab Pen Plus 有真实 HID Host 链路时发布原生笔连接状态，不改笔固件。电量、充电和版本分别读 BLE 电池与设备信息服务；单实体键映射到现有工具切换和区域截屏，保留关闭选项与锁屏限制。补丁文件为 `native-pen/hid-bridge.methods`、`PlusGatt.smali`、`PlusUi.smali` 和 `PlusButtons.smali`。早期参考的 TB710FU Tab Pen Pro 方案只用来了解系统入口，不移植其内核、GPIO 或笔协议。

Precision Pen 3 实验分支按蓝牙名称精确匹配，在已配对且 HID Host 确认连接时复用同一套连接状态发布。两款笔同时在线时优先使用 Tab Pen Plus。Precision Pen 3 走原厂通用笔设置路径，隐藏可能残留的电量。该型号的实验 GATT 路径只读取和订阅电池电量及电源状态。设备信息和笔键处理仍只用于 Tab Pen Plus。

`PenCapsule.smali` 用原厂 `CapsuleImpl` 与笔图标显示连接提示。Precision Pen 3 的充电提示通过 BLE 电池服务 `180F/2A1A` 识别，等连接提示消失后显示。同一次充电的重复通知会被合并。系统支持流体云且读到了当前笔的真实电量时调用原厂 Seedling 电量卡，充电动画在本次渲染时使用 BLE 确认的电源状态。其他情况使用原厂普通胶囊。此路径不会向系统注入磁吸事件。

把本机原 `IPeManager.apk` 以 `IPeManager.stock.apk` 放在脚本旁，使用 Java 17、smali/baksmali 2.5.2 及其依赖执行：

```sh
SMALI_TOOLS=/path/to/smali-jars JAVA=java python3 native-pen/build-classifier.py --hid-bridge --plus-telemetry
```

开机后只在主 Zygote 命名空间绑定候选，重启 IPeManager 服务并校验新 BLE 进程的 APK。不能只看全局连接设置，因为旧值可在重启后残留。Binder 命令的输出先经管道接收，避免 `system_server` 继承不能写的私有日志描述符。

原生笔 APK 的整合输入按 `inputs.lock.json` 固定。v1.0.2-beta.1 的输入 ZIP 只含构建所得的 `IPeManager.plus-telemetry.apk`。与 v1.0.1 的 APK 对比，反汇编后只有 `PencilBleManager` 和 `PlusUi` 两个类有改动。

## 发布范围

Git 跟踪修复脚本、说明和源码；Release 只附已经过实机验收的综合模块 ZIP。源码树不包含 ROM、供体二进制、设备日志、序列号、蓝牙地址或旧回退素材。第三方许可和来源见 [NOTICE](../NOTICE.md)。
