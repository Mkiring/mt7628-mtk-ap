# MT7628 MTK WiFi AP Driver for OpenWrt

MediaTek MT7628/MT7688 官方 WiFi AP 驱动（v4.1.1.0）的 OpenWrt 移植版本。

## 特性

- 基于 MediaTek 官方 SDK v4.1.1.0（最后发布版本，2019年）
- 已适配 Linux 5.4 内核 API（定时器、设备树资源解析等）
- 支持 AP/STA/WDS/Repeater 模式
- 相比开源 mt76 驱动更稳定，性能更高

## 编译要求

```bash
# 在 OpenWrt 构建环境中添加此包
git clone https://github.com/Mkiring/mt7628-mtk-ap.git package/mt7628-mtk-ap
```

### 配置 Makefile

在 OpenWrt `.config` 中添加：

```bash
# 启用闭源驱动
echo 'CONFIG_PACKAGE_kmod-mt7628-mtk-ap=m' >> .config

# ⚠️ 重要：禁用冲突的开源驱动 mt7603（否则会导致 kernel panic）
echo 'CONFIG_PACKAGE_kmod-mt7603=""' >> .config

make defconfig
```

### 编译

```bash
# 清理之前的构建
make package/mt7628-mtk-ap/clean V=s

# 编译模块
make package/mt7628-mtk-ap/compile V=s

# 完整固件编译
make -j$(nproc) V=s
```

编译成功后输出文件：
- `bin/targets/ramips/mt76x8/packages/kmod-mt7628-mtk-ap_*.ipk`
- `build_dir/.../mt7628.ko`

## 设备安装

### 方法 1：通过 opkg 安装（推荐）

```bash
# 将 ipk 传输到设备
scp bin/targets/ramips/mt76x8/packages/kmod-mt7628-mtk-ap_*.ipk root@192.168.1.1:/tmp/

# SSH 登录并安装
ssh root@192.168.1.1
opkg install /tmp/kmod-mt7628-mtk-ap_*.ipk

# 检查模块是否加载
lsmod | grep mt7628
dmesg | grep -i mt7628
```

### 方法 2：手动加载模块

```bash
# 复制 .ko 文件到设备
scp build_dir/.../mt7628_wifi/embedded/mt7628.ko root@192.168.1.1:/tmp/

# 手动加载
ssh root@192.168.1.1
insmod /lib/modules/$(uname -r)/mt7628.ko

# 验证
iw dev
dmesg | grep -i "mt7628.*DT resources"
# 应该看到类似: mt7628: DT resources: mem=0x10300000, irq=6
```

## 设备树配置

**必须**在目标设备的 DTS 中启用 wmac 节点：

```dts
&wmac {
    status = "okay";
    mediatek,mtd-eeprom = <&factory 0x0000>;
};
```

驱动会优先从设备树读取地址和中断：
- 寄存器基地址：`reg = <0x10300000 0x100000>` → `0x10300000`
- 中断号：`interrupts = <6>` → IRQ 6

如果设备树未配置，会自动回退到硬编码值（`0xB0300000`, IRQ 4）。

## 常见接口名称

| 接口名 | 说明 |
|--------|------|
| `ra0` | 主 AP 接口（MTK 传统命名） |
| `wlan0` | 标准 cfg80211 接口 |
| `ra1`, `ra2`... | 多 SSID (VAP) 接口 |

## 网络配置

编辑 `/etc/config/wireless`：

```bash
config wifi-device 'radio0'
    option type 'mac80211'
    option hwmode '11g'
    option path 'platform/mt7628-wmac'
    option channel '6'
    option htmode 'HT20'
    option country 'CN'

config wifi-iface 'default_radio0'
    option device 'radio0'
    option network 'lan'
    option mode 'ap'
    option ssid 'OpenWrt-MTK'
    option encryption 'psk2'
    option key 'your-password'
```

应用配置：
```bash
wifi reload
# 或
/etc/init.d/network restart
```

## 诊断命令

```bash
# 检查模块加载状态
lsmod | grep mt7628

# 查看内核日志
dmesg | grep -i mt7628

# 检查无线接口
iw dev
ifconfig -a | grep -E "ra|wlan"

# 检查频率/信道
iw list
iw phy

# 测试无线功能
iw dev wlan0 interface add mon0 type monitor
iw dev mon0 set channel 6
iw dev mon0 up
```

## 故障排除

### 问题 1：Kernel Panic（双驱动冲突）

**症状**：系统启动时崩溃，dmesg 显示两个驱动尝试绑定同一设备。

**原因**：`kmod-mt7603`（开源 mt76 驱动）与 `kmod-mt7628-mtk-ap` 同时加载。

**解决**：
```bash
# 禁用开源驱动
echo 'CONFIG_PACKAGE_kmod-mt7603=""' >> .config
make defconfig
make package/mt7628-mtk-ap/compile V=s
```

### 问题 2：没有无线接口

**检查列表**：
```bash
# 确认模块已加载
lsmod | grep mt7628

# 检查设备树配置
cat /proc/device-tree/wmac/status

# 查看内核日志
dmesg | grep -i "mt7628\|wmac\|ieee80211"
```

### 问题 3：固件缺失

```bash
# 确认固件文件存在
ls /lib/firmware/mt7628_e{1,2}.bin

# 如果缺少，从编译目录复制
cp staging_dir/.../root-ramips/lib/firmware/mt7628_*.bin /tmp/
scp /tmp/mt7628_*.bin root@device:/lib/firmware/
```

### 问题 4：无法设置信道/功率

MTK 驱动使用私有 ioctl，通过 `iwpriv` 控制：
```bash
# 查看可用命令
iwpriv ra0 show

# 设置发射功率 (0-100%)
iwpriv ra0 set TxPower=100

# 设置带宽 (0=20MHz, 1=40MHz)
iwpriv ra0 set HtBw=1
```

## 已知限制

1. **无 LuCI Web 界面**：需手动编辑 `/etc/config/wireless`
2. **MAC 地址来源**：依赖设备树中的 `mediatek,mtd-eeprom` 属性
3. **硬件兼容性**：主要针对 MT7628AN/MT7688 SoC，其他芯片可能需要额外修改
4. **单驱动模式**：必须禁用开源 mt76 驱动，不能共存

## 与开源 mt76 驱动对比

| 特性 | MTK 闭源驱动 | 开源 mt76 |
|------|-------------|-----------|
| 性能 | 更高 | 良好 |
| 稳定性 | 更好 | 偶有断流 |
| 功能完整性 | 完整（AP/STA/WDS/APCLI） | 基本功能 |
| 维护状态 | 已停止（2019年后） | 活跃开发 |
| 许可证 | GPL（二进制分发受限） | ISC |
| 设备树支持 | ✅ 已添加 | ✅ 原生支持 |

## Git 仓库

- **源码**：https://github.com/Mkiring/mt7628-mtk-ap
- **分支**：`main`（当前稳定版）
- **OpenWrt 集成**：作为 OpenWrt feed 使用

## 贡献

欢迎提交 Issue 和 Pull Request！请确保：
1. 所有代码变更附带补丁文件
2. 更新 README 中的相关说明
3. 在目标设备上测试后再提交 PR
