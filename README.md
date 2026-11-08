# MT7628 MTK WiFi 驱动移植状态报告

## 当前状态

### 已完成的工作

1. **创建新的驱动包结构**
   - 位置：`package/mt7628-mtk-ap/`
   - 源代码：已从 MTK SDK v4.1.1.0 复制
   - Makefile：已创建并适配 OpenWrt 21.02

2. **Prepare 阶段**
   - ✅ 成功执行
   - 源代码已正确复制到构建目录

3. **创建内核兼容性补丁**
   - 文件：`package/mt7628-mtk-ap/patches/001-linux-5.4-timer-compat.patch`
   - 文件：`package/mt7628-mtk-ap/patches/002-linux-5.4-misc-compat.patch`
   - 目标：修复 Linux 5.4 内核 API 变化

### 主要问题

#### 1. 内核版本差异（Linux 5.4 vs 旧版本）

**定时器 API 变化（Linux 4.15+）**
```c
// 旧 API（已移除）
init_timer(timer);
timer->data = (unsigned long)data;
timer->function = callback;

// 新 API
timer_setup(timer, callback, 0);
// 回调函数签名也变了：
// 旧：void callback(unsigned long data)
// 新：void callback(struct timer_list *timer)
```

**其他 API 变化**
- `class_create()` 参数变化（Linux 6.4+）
- 网络设备操作接口可能有变化
- PCI 驱动接口可能有变化

#### 2. 编译依赖问题

- 需要正确的内核配置
- 需要正确的编译选项

## 下一步工作

### 1. 测试编译

```bash
# 清理
make package/mt7628-mtk-ap/clean

# 准备（已完成）
make package/mt7628-mtk-ap/prepare V=s

# 编译（需要先确保内核已编译）
make package/mt7628-mtk-ap/compile V=s
```

### 2. 修复编译错误

预期会遇到的问题：
1. **定时器回调函数签名不匹配**
   - 需要修改所有定时器回调函数
   - 使用 `from_timer()` 宏获取数据

2. **缺少头文件或宏定义**
   - 可能需要添加更多的兼容性宏

3. **内核配置选项**
   - 需要确保 `CONFIG_MT7628_AP_SUPPORT` 等选项正确设置

### 3. 创建完整的内核 5.4 兼容层

建议创建一个统一的兼容性头文件：

```c
// include/linux_5.4_compat.h
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 15, 0)
// 定时器兼容性
#define init_timer(timer) timer_setup(timer, NULL, 0)
#define setup_timer(timer, fn, data) \
    timer_setup(timer, (void (*)(struct timer_list *))fn, 0)

// 其他兼容性宏...
#endif
```

### 4. 测试和验证

1. 编译成功后，安装到设备
2. 测试基本功能：
   - AP 模式
   - Station 模式
   - WDS/Repeater 模式
3. 对比开源 mt76 驱动的稳定性

## 技术细节

### 驱动架构

```
mt7628_wifi/
├── embedded/          # 核心驱动代码
│   ├── ap/           # AP 模式
│   ├── sta/          # Station 模式
│   ├── common/       # 通用功能
│   ├── os/linux/     # Linux 内核接口（主要修改点）
│   └── mcu/          # MCU 固件
├── include/          # 头文件
├── chips/            # 芯片特定代码
├── mac/              # MAC 层
└── phy/              # PHY 层
```

### 关键文件

1. **`embedded/os/linux/rt_linux.c`**
   - 主要的内核接口实现
   - 定时器、网络设备、内存管理等
   - 需要大量修改以适配 Linux 5.4

2. **`embedded/include/os/rt_linux.h`**
   - OS 抽象层定义
   - 需要添加兼容性宏

3. **`embedded/os/linux/rt_main_dev.c`**
   - 主设备初始化
   - 模块加载/卸载

### MTK 官方驱动 vs 开源 mt76 驱动

| 特性 | MTK 官方驱动 | 开源 mt76 驱动 |
|------|-------------|---------------|
| 性能 | 更高 | 较低 |
| 稳定性 | 更好 | 有断流问题 |
| 功能 | 完整（AP/STA/WDS/Repeater） | 基本功能 |
| 维护 | 已停止 | 活跃 |
| 许可证 | 闭源 | 开源 |

## 建议

1. **优先修复定时器 API**：这是最关键的兼容性问题
2. **逐步测试**：先让驱动编译通过，再测试功能
3. **保留补丁**：所有修改都应该以补丁形式保存，方便后续维护
4. **文档记录**：记录所有 API 变化和修复方法

## 参考资料

- Linux 内核文档：`Documentation/timers/timer_setup.rst`
- OpenWrt 驱动开发指南
- MediaTek SDK 文档
