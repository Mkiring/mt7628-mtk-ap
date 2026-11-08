# MT7628 WiFi AP Driver - Configuration Guide

## 驱动状态

### ✅ 编译成功
- **内核模块**: `mt7628.ko` (8.5MB)
- **IPK 包**: `kmod-mt7628-mtk-ap_5.4.238+4.1.1.0-1_mipsel_24kc.ipk` (665KB)
- **内核版本**: 5.4.238
- **架构**: MIPS32_R2 (mipsel_24kc)

### ⚠️ 注意事项

1. **无 LuCI 配置界面**: 此驱动包不包含 LuCI Web 配置界面
2. **使用硬编码地址**: 驱动使用固定的内存地址 (0xB0300000) 和中断号 (4)
3. **cfg80211 支持**: 驱动支持 cfg80211，可与标准无线工具配合使用

## 安装方法

### 方法 1: 使用 opkg 安装（推荐）

```bash
# 复制 IPK 包到设备
scp kmod-mt7628-mtk-ap_*.ipk root@192.168.1.1:/tmp/

# SSH 到设备
ssh root@192.168.1.1

# 安装
opkg install /tmp/kmod-mt7628-mtk-ap_*.ipk

# 模块会自动加载，检查状态
lsmod | grep mt7628
```

### 方法 2: 手动加载模块

```bash
# 复制 .ko 文件到设备
scp mt7628.ko root@192.168.1.1:/lib/modules/5.4.238/

# SSH 到设备
ssh root@192.168.1.1

# 加载模块
insmod /lib/modules/5.4.238/mt7628.ko

# 或带参数加载
insmod /lib/modules/5.4.238/mt7628.ko mac=00:11:22:33:44:55 mode=AP
```

## 配置方法

### 1. 检查无线接口

```bash
# 查看网络接口
ifconfig -a | grep -E "wlan|ra"

# 查看无线设备
iw dev

# 查看详细无线信息
iw phy
```

### 2. 使用 /etc/config/wireless 配置

驱动加载后，如果创建了 `wlan0` 接口，可以编辑 `/etc/config/wireless`:

```bash
config wifi-device 'wlan0'
    option type 'mt7628'
    option country 'CN'
    option channel 'auto'
    option hwmode '11g'
    option htmode 'HT20'

config wifi-iface
    option device 'wlan0'
    option network 'lan'
    option mode 'ap'
    option ssid 'MyWiFi'
    option encryption 'psk2'
    option key 'MyPassword123'
```

应用配置：
```bash
wifi reload
# 或
/etc/init.d/network restart
```

### 3. 使用 iw 命令手动配置

```bash
# 创建 AP 接口
iw dev wlan0 interface add wlan1 type __ap

# 设置信道
iw dev wlan1 set channel 6

# 启动接口
ifconfig wlan1 up
```

### 4. 使用驱动内置的 ioctl 接口

MTK 驱动提供了私有 ioctl 接口，可以通过 `iwpriv` 命令配置：

```bash
# 查看支持的 ioctl 命令
iwpriv wlan0 show

# 设置 SSID
iwpriv wlan0 set SSID=MyWiFi

# 设置信道
iwpriv wlan0 set Channel=6

# 设置加密
iwpriv wlan0 set AuthMode=WPAPSK
iwpriv wlan0 set EncrypType=AES
iwpriv wlan0 set WPAPSK=MyPassword123
```

## 常见接口名称

MTK 驱动可能创建以下接口：
- `ra0` - 主 AP 接口
- `ra1`, `ra2`... - 多 SSID (VAP) 接口
- `wlan0`, `wlan1`... - 标准无线接口

## 验证驱动工作状态

### 1. 检查模块加载

```bash
lsmod | grep mt7628
# 应该看到:
# mt7628 1234567 0 - Live 0xffffffff
```

### 2. 检查内核日志

```bash
dmesg | grep -i mt7628
# 应该看到驱动初始化信息
```

### 3. 检查 proc 文件系统

```bash
# 驱动可能在 /proc 下创建信息节点
ls -l /proc/rt2880/
cat /proc/rt2880/ver  # 查看版本
```

### 4. 检查 sysfs

```bash
ls -l /sys/class/net/ | grep -E "wlan|ra"
```

## 故障排除

### 问题 1: 模块加载失败

```bash
# 检查内核版本是否匹配
uname -r
# 应该显示: 5.4.238

# 检查模块依赖
modinfo mt7628.ko | grep depends
```

### 问题 2: 没有无线接口

```bash
# 检查 dmesg 错误
dmesg | grep -i "mt7628\|error\|fail"

# 检查内存地址是否正确
cat /proc/iomem | grep -i wifi
```

### 问题 3: 接口无法启动

```bash
# 检查射频状态
rfkill list

# 如果被阻止，解除阻止
rfkill unblock all
```

## 性能调优

### 1. 设置发射功率

```bash
iwpriv ra0 set TxPower=100  # 100%
```

### 2. 设置带宽

```bash
iwpriv ra0 set HtBw=1  # 0=20MHz, 1=40MHz
```

### 3. 设置信道

```bash
iwpriv ra0 set Channel=6
```

## 与开源 mt76 驱动的比较

| 特性 | MTK 闭源驱动 | 开源 mt76 |
|------|-------------|----------|
| 性能 | 更优 | 良好 |
| 稳定性 | 更稳定 | 稳定 |
| 功能 | 完整 | 基本功能 |
| 维护 | 已停止更新 | 持续更新 |
| 配置 | iwpriv | 标准工具 |
| LuCI | 需要额外开发 | 原生支持 |

## 建议

1. **首次测试**: 建议先在测试环境验证驱动功能
2. **性能对比**: 可以同时编译 mt76 开源驱动进行对比测试
3. **配置工具**: 如需 Web 界面，需要开发配套的 LuCI 应用
4. **文档参考**: 查看原始 SDK 文档了解更多配置选项

## 相关文件

- 内核模块: `/lib/modules/5.4.238/mt7628.ko`
- 配置文件: `/etc/config/wireless`
- 测试脚本: `/usr/bin/test_driver.sh`
