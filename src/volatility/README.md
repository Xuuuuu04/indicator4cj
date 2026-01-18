# indicator4cj.volatility - 波动率指标包

## 版本
v1.0.0

## 包简介
`volatility` 包提供了衡量市场波动率和风险的技术指标。这些指标用于评估价格变动的剧烈程度，识别潜在的突破和反转点，以及设置止损止盈位置。

## 核心指标列表

### 1. 布林带系列

#### Bollinger Bands (布林带)
**文件**：`bollinger_bands.cj`

**计算公式**：
- 中轨 = SMA(收盘价, N)
- 上轨 = 中轨 + k × 标准差
- 下轨 = 中轨 - k × 标准差

**默认参数**：
- 周期 N：20
- 标准差倍数 k：2.0

**特点**：
- 动态调整带宽
- 基于统计学的正态分布
- 波动率越大，带宽越宽

**交易信号**：
- 价格触及上轨：可能的超买信号
- 价格触及下轨：可能的超卖信号
- 布林带收缩（Squeeze）：预示即将突破
- 价格突破中轨：趋势改变信号

**创建者**：John Bollinger（1980年代）

---

#### Bollinger Band Width (布林带宽度)
**文件**：`bollinger_band_width.cj`

**计算公式**：BB Width = (上轨 - 下轨) / 中轨 × 100

**用途**：
- 衡量波动率
- 识别低波动期（收缩）
- 预测突破时机

**特点**：
- 标准化波动率指标
- 值越小表示波动率越低
- 常用于识别盘整末期

---

#### Percent B (%B) - 百分比布
**文件**：`percent_b.cj`

**计算公式**：%B = (价格 - 下轨) / (上轨 - 下轨)

**取值范围**：0-1（可以超出）

**用途**：
- %B > 1：价格突破上轨
- %B < 0：价格跌破下轨
- %B = 0.5：价格在中轨

**特点**：
- 标准化布林带位置
- 便于不同品种比较
- 识别极端价格位置

---

### 2. 通道指标

#### Keltner Channel (肯特纳通道)
**文件**：`keltner_channel.cj`

**计算公式**：
- 中轨 = EMA(收盘价, N)
- 上轨 = 中轨 + k × ATR
- 下轨 = 中轨 - k × ATR

**默认参数**：
- EMA 周期：20
- ATR 倍数：2.0

**特点**：
- 基于 ATR（真实波动幅度）
- 比布林带更平滑
- 适合趋势跟踪

**用途**：
- 趋势识别
- 动态止损止盈
- 突破交易

---

#### Donchian Channel (唐奇安通道)
**文件**：`donchian_channel.cj`

**计算公式**：
- 上轨 = N周期最高价
- 下轨 = N周期最低价
- 中轨 = (上轨 + 下轨) / 2

**默认周期**：20

**特点**：
- 基于极值价格
- 简单直观
- 著名的海龟交易法则核心

**交易信号**：
- 突破上轨：买入信号
- 突破下轨：卖出信号

---

### 3. 波动率测量

#### ATR (Average True Range) - 平均真实波动幅度
**文件**：`atr.cj`

**计算公式**：
1. 真实波动幅度 TR = max(最高价-最低价, |最高价-前收盘|, |最低价-前收盘|)
2. ATR = SMA(TR, N)

**默认周期**：14

**用途**：
- 衡量市场波动率
- 设置止损止盈距离
- 调整仓位大小

**特点**：
- 考虑跳空因素
- 不指示方向
- 由 J. Welles Wilder 开发

**应用示例**：
- 止损距离 = 2 × ATR
- 仓位大小 = 账户风险 / (2 × ATR)

---

#### Moving Std (移动标准差)
**文件**：`moving_std.cj`

**计算公式**：Std = √[Σ(价格 - 均值)² / N]

**默认周期**：20

**用途**：
- 计算价格波动率
- 布林带的组成部分
- 风险管理

---

### 4. 趋势跟踪指标

#### Super Trend (超级趋势)
**文件**：`super_trend.cj`

**计算公式**：
- 基础线 = (最高价 + 最低价) / 2 ± k × ATR
- 根据价格与基础线的关系确定趋势方向

**默认参数**：
- ATR 周期：10
- ATR 倍数：3.0

**用途**：
- 识别主趋势方向
- 动态止损线
- 趋势跟踪

**特点**：
- 简单易用
- 减少假信号
- 适合趋势市场

**交易信号**：
- 绿线（上升趋势）：持有多头
- 红线（下降趋势）：持有空头或观望

---

### 5. 止损指标

#### Chandelier Exit (吊灯止损)
**文件**：`chandelier_exit.cj`

**计算公式**：
- 多头止损 = N周期最高价 - k × ATR
- 空头止损 = N周期最低价 + k × ATR

**默认参数**：
- 周期：22
- ATR 倍数：3.0

**用途**：
- 动态止损位
- 保护利润
- 跟踪趋势

**特点**：
- 由 Chuck LeBeau 开发
- 类似吊灯悬挂在最高点下方
- 适合趋势跟踪策略

---

### 6. 其他波动率指标

#### Acceleration Bands (加速度带)
**文件**：`acceleration_bands.cj`

**计算公式**：
- 上轨 = SMA(高价 × (1 + k × (高价-低价)/(高价+低价)))
- 下轨 = SMA(低价 × (1 - k × (高价-低价)/(高价+低价)))

**默认参数**：
- SMA 周期：20
- 加速度系数：0.001

**特点**：
- 基于价格加速度
- 自适应带宽
- 识别价格加速

---

#### Ulcer Index (溃疡指数)
**文件**：`ulcer_index.cj`

**计算公式**：
UI = √[Σ(百分比回落²) / N]

**用途**：
- 衡量下行风险
- 评估投资组合风险
- 比较不同策略

**特点**：
- 只关注下行风险
- 由 Peter Martin 开发
- 值越低风险越小

---

#### PO (Probability Oscillator) - 概率振荡器
**文件**：`po.cj`

**特点**：
- 基于统计概率
- 衡量价格偏离程度
- 识别异常波动

---

## 使用示例

### 示例 1：布林带突破策略

```cangjie
import indicator4cj.volatility.*

let closes = loadClosePrices()

// 计算布林带
let bb = BollingerBands(20, 2.0)
let (upper, middle, lower) = bb.compute(closes.iterator())

// 突破交易策略
for ((u, m, l, price) in zip4(upper, middle, lower, closes)) {
    if (let Some(upperVal) <- u,
        let Some(middleVal) <- m,
        let Some(lowerVal) <- l) {

        // 突破上轨
        if (price > upperVal) {
            println("突破上轨：强烈买入信号")
        }
        // 跌破下轨
        else if (price < lowerVal) {
            println("跌破下轨：强烈卖出信号")
        }
        // 回归中轨
        else if (price > middleVal) {
            println("上升趋势中")
        } else {
            println("下降趋势中")
        }
    }
}
```

### 示例 2：ATR 止损策略

```cangjie
import indicator4cj.volatility.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()

// 计算 ATR
let atr = Atr(14)
let atrValues = atr.compute(highs.iterator(), lows.iterator(), closes.iterator())

// 设置动态止损
let atrMultiplier = 2.0
for ((atr, close) in zip(atrValues, closes)) {
    if (let Some(atrVal) <- atr) {
        let stopLoss = close - (atrVal * atrMultiplier)
        println("当前价格：${close}，止损位：${stopLoss}")
    }
}
```

### 示例 3：Super Trend 趋势跟踪

```cangjie
import indicator4cj.volatility.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()

// 计算 Super Trend
let superTrend = SuperTrend(10, 3.0)
let (trend, signal) = superTrend.compute(highs.iterator(), lows.iterator(), closes.iterator())

// 趋势跟踪策略
for ((t, s, price) in zip3(trend, signal, closes)) {
    if (let Some(trendVal) <- t,
        let Some(signalVal) <- s) {

        if (signalVal > 0) {
            println("上升趋势，持有，止损：${signalVal}")
        } else {
            println("下降趋势，观望，阻力：${signalVal}")
        }
    }
}
```

## 注意事项

1. **波动率与趋势**：波动率指标不直接指示方向，需要配合趋势指标
2. **参数选择**：默认参数适合大多数市场，但应根据品种特性调整
3. **假突破**：低波动后的突破可能是假信号，应等待确认
4. **止损距离**：ATR 倍数应根据风险偏好和交易周期调整
5. **布林带收缩**：收缩时间越长，后续突破越有力

## 典型应用场景

1. **趋势跟踪**：Super Trend、Chandelier Exit 用于动态止损
2. **突破交易**：布林带收缩后等待突破
3. **风险管理**：ATR 用于计算仓位大小和止损距离
4. **波动率分析**：布林带宽度衡量市场活跃度
5. **风险度量**：Ulcer Index 评估策略下行风险

## 依赖关系

- **indicator4cj.helper** - 辅助函数和流式处理工具
- **indicator4cj.trend** - 移动平均线等趋势指标

## 版本历史

### v1.0.0 (2024)
- 初始版本
- 实现所有主流波动率指标
- 支持布林带系列指标
- 支持多种通道指标
- 提供完整的测试覆盖
