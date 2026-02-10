# LEDWF - LED Watch Face

Garmin Connect IQ 手表表盘项目，采用 LED 点阵风格显示时间和多种健康/状态数据。

## 项目信息

- **语言**: Monkey C
- **类型**: Watch Face
- **目标设备**: Fenix 7 Pro
- **最低 API**: 5.2.0

## 项目结构

```
LEDWF/
├── source/
│   ├── LEDWFApp.mc        # 应用入口
│   ├── LEDWFView.mc       # 主视图 - LED点阵绘制逻辑
│   └── LEDWFBackground.mc # 后台服务
├── resources/
│   ├── drawables/         # 图标资源
│   ├── layouts/           # 布局定义
│   ├── settings/          # 设置和属性
│   └── strings/           # 字符串资源
├── manifest.xml           # 应用清单
└── monkey.jungle          # 构建配置
```

## 表盘布局

```
            😊                   <- 身体电量表情
        星期       日期          <- 星期 + 月.日
        HH:MM  AM/PM            <- 时间 + AM/PM（右侧）
     ══════════════════          <- 电池进度条
   👣 ●●●  ♥  ●●● 🔥            <- 步数饼图 + 心形 + 卡路里饼图
             72                  <- 心率
        ▪▪▪▪▪▪▪                  <- 一周运动格子
```

## 核心实现 (LEDWFView.mc)

### 点阵配置
- `_dotSize`: LED 点的直径（像素），默认 5
- `_dotSpacing`: 点之间的间距（像素），默认 5
- 根据屏幕尺寸自动调整：大屏(≥416) 6/6 / 中屏(≥280) 5/5 / 小屏 4/4

### 点阵模式
| 类型 | 尺寸 | 用途 |
|------|------|------|
| `_digitPatterns` | 6x12 | 时间大数字 |
| `_smallDigitPatterns` | 4x5 | 日期数字 |
| `_tinyDigitPatterns` | 3x5 | 心率数字 |
| `_letterPatterns` | 4x5 | 星期字母 + AM/PM |
| `_heartPattern` | 5x4 | 心形图标 |
| `_faceHappy/Neutral/Sad` | 9x9 | 身体电量表情 |

### 显示内容
- **时间**：HH:MM，冒号每秒闪烁，冒号居中于屏幕水平中央
- **AM/PM**：在时间右侧，12小时制指示，竖排显示
- **星期**：三字母缩写 (MON, TUE, WED, THU, FRI, SAT, SUN)
- **日期**：MM.DD 格式
- **身体电量**：表情图标（😊/😐/😢），根据 Body Battery 值变化
- **心率**：心形图标 + 数值（每秒闪烁）
- **电池**：进度条样式（10组点阵，水平居中）
- **步数**：饼状图 + 脚印图标（心形左侧）
- **卡路里**：饼状图 + 火焰图标（心形右侧）
- **秒针跑马灯**：外圈60个点，当前秒高亮
- **一周运动**：7个方块，步数>5000为亮

### 颜色方案
- `_ledOn`: 0xFFFFFF (白色 - LED亮)
- `_ledOff`: 0x333333 (深灰 - LED灭)
- `_bgColor`: 0x000000 (黑色背景)
- `_heartColor`: 0xFFFFFF (白色 - 心形)

### 权限要求
- `SensorHistory`: 心率历史数据
- `Sensor`: 海拔等传感器数据

## 构建和调试

使用 VS Code + Garmin Connect IQ 插件：

```bash
# 构建
Ctrl+Shift+P -> "Monkey C: Build for Device"

# 运行模拟器
Ctrl+Shift+P -> "Monkey C: Run in Simulator"
```

## 修改指南

### 调整点阵密度
修改 `LEDWFView.mc` 中的 `_dotSize` 和 `_dotSpacing`：
- 密度 = dotSize / dotSpacing
- dotSize = dotSpacing 时点几乎相邻

### 添加新字母
1. 在 `_letterPatterns` 数组中添加 4x5 点阵
2. 在 `getLetterPatternIndex()` 中添加映射

### 添加新图标
1. 定义图标尺寸变量：`_xxxCols`, `_xxxRows`
2. 定义点阵模式：`_xxxPattern`
3. 添加绘制函数：`drawXxxIcon()`
4. 在 `onUpdate()` 中调用绘制

### 修改颜色
直接修改 `_ledOn`、`_ledOff`、`_bgColor` 的十六进制值

### 性能优化
- **三角函数预计算**：秒针跑马灯(60点)和饼状图(24点×2)的坐标在 `onLayout` 阶段预计算并缓存，`onUpdate` 中零 `Math` 调用
- **缓存变量**：`_marqueeX/Y`、`_pieCWDx/Dy`、`_pieCCWDx/Dy`

### 数据获取函数
- `getHeartRate()`: 心率 (ActivityMonitor)
- `getSteps()`: 步数 (ActivityMonitor)
- `getStepGoal()`: 步数目标 (ActivityMonitor)
- `getCalories()`: 卡路里 (ActivityMonitor)
- `getCalorieGoal()`: 卡路里目标 (ActivityMonitor)
- `getBodyBattery()`: 身体电量 (SensorHistory)
- `getWeeklyActivity()`: 一周运动情况 (ActivityMonitor)
