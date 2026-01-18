# indicator4cj.trend - 趋势指标包

## 版本
v1.0.0

## 包简介
`trend` 包包含了所有与价格趋势相关的技术指标，用于识别和跟踪市场趋势方向。这些指标可以帮助交易者判断市场的上升、下降或横盘趋势。

## 核心指标列表

### 1. 移动平均线系列

#### SMA (Simple Moving Average) - 简单移动平均线
**文件**：`sma.cj`

**计算公式**：SMA = (P1 + P2 + ... + Pn) / n

**特点**：
- 权重均等：所有数据点权重相同
- 计算简单：易于理解和计算
- 滞后性：对近期价格变化反应较慢
- 稳定性好：不易受短期价格波动影响

**默认周期**：30

**用途**：
- 识别趋势方向
- 生成支撑/阻力位
- 价格交叉信号（金叉/死叉）

---

#### EMA (Exponential Moving Average) - 指数移动平均线
**文件**：`ema.cj`

**计算公式**：EMA = Price × k + EMA(前值) × (1 - k)，其中 k = 2 / (period + 1)

**特点**：
- 权重递减：近期数据权重更高
- 反应迅速：对价格变化敏感
- 减少滞后：相比 SMA 更快反应趋势变化

**默认周期**：30

---

#### WMA (Weighted Moving Average) - 加权移动平均线
**文件**：`wma.cj`

**计算公式**：WMA = (P1×1 + P2×2 + ... + Pn×n) / (1 + 2 + ... + n)

**特点**：
- 线性权重：权重线性递增
- 介于 SMA 和 EMA 之间

**默认周期**：9

---

#### HMA (Hull Moving Average) - 赫尔移动平均线
**文件**：`hma.cj`

**特点**：
- 几乎零滞后
- 平滑度高
- 适用于各种市场条件

**默认周期**：9

---

#### DEMA (Double Exponential Moving Average) - 双指数移动平均线
**文件**：`dema.cj`

**计算公式**：DEMA = 2 × EMA - EMA(EMA)

**特点**：
- 减少滞后
- 保持平滑度
- 由 Patrick Mulloy 提出

**默认周期**：20

---

#### TEMA (Triple Exponential Moving Average) - 三指数移动平均线
**文件**：`tema.cj`

**计算公式**：TEMA = 3 × EMA - 3 × EMA(EMA) + EMA(EMA(EMA))

**特点**：
- 更少滞后
- 更快反应

**默认周期**：20

---

#### TRIMA (Triangular Moving Average) - 三角移动平均线
**文件**：`trima.cj`

**特点**：
- 双重平滑
- 类似 SMA 的加权版本

**默认周期**：30

---

#### SMMA (Smoothed Moving Average) - 平滑移动平均线
**文件**：`smma.cj`

**特点**：
- 类似 EMA 但计算方式不同
- 常用于 RSI 计算

**默认周期**：30

---

#### RMA (Running Moving Average) - 运行移动平均线
**文件**：`rma.cj`

**特点**：
- 增量计算
- 适合流式数据

**默认周期**：30

---

#### VWMA (Volume Weighted Moving Average) - 成交量加权移动平均线
**文件**：`vwma.cj`

**计算公式**：VWMA = Σ(Price × Volume) / Σ(Volume)

**特点**：
- 考虑成交量权重
- 更准确反映市场情绪

**默认周期**：30

---

#### KAMA (Kaufman's Adaptive Moving Average) - 考夫曼自适应移动平均线
**文件**：`kama.cj`

**特点**：
- 自适应调整平滑度
- 在趋势市场中快速反应
- 在震荡市场中平滑波动

**默认周期**：30

---

### 2. 趋势跟踪指标

#### MACD (Moving Average Convergence Divergence) - 异同移动平均线
**文件**：`macd.cj`

**计算公式**：
- MACD 线 = EMA(12) - EMA(26)
- 信号线 = EMA(MACD, 9)
- 柱状图 = MACD - 信号线

**默认参数**：
- 快线周期：12
- 慢线周期：26
- 信号线周期：9

**用途**：
- 趋势确认
- 动量分析
- 买卖信号（金叉/死叉）

---

#### APO (Absolute Price Oscillator) - 绝对价格振荡器
**文件**：`apo.cj`

**计算公式**：APO = EMA(快线) - EMA(慢线)

**默认参数**：
- 快线周期：14
- 慢线周期：30

---

#### TRIX (Triple Exponential Average) - 三重指数平滑平均线
**文件**：`trix.cj`

**特点**：
- 过滤短期噪音
- 识别趋势反转

**默认周期**：30

---

#### DPO (Detrended Price Oscillator) - 去趋势价格振荡器
**文件**：`dpo.cj`

**特点**：
- 消除趋势影响
- 识别周期性高低点

**默认周期**：30

---

#### ROC (Rate of Change) - 变化率
**文件**：`roc.cj`

**计算公式**：ROC = (当前价格 - N周期前价格) / N周期前价格 × 100

**默认周期**：30

---

#### TSI (True Strength Index) - 真实强度指数
**文件**：`tsi.cj`

**特点**：
- 衡量趋势强度
- 过滤市场噪音

**默认参数**：
- 快线周期：25
- 慢线周期：13

---

### 3. 通道指标

#### Envelope - 包络线
**文件**：`envelope.cj`

**计算公式**：
- 上轨 = SMA × (1 + 偏移百分比)
- 下轨 = SMA × (1 - 偏移百分比)

**默认参数**：
- 周期：30
- 偏移：0.1 (10%)

---

### 4. 动量振荡指标

#### Aroon - 阿隆指标
**文件**：`aroon.cj`

**组成**：
- Aroon Up：衡量上涨趋势强度
- Aroon Down：衡量下跌趋势强度
- Aroon Oscillator：Aroon Up - Aroon Down

**默认周期**：25

**用途**：
- 识别趋势变化
- 测量趋势强度

---

#### CCI (Commodity Channel Index) - 商品通道指标
**文件**：`cci.cj`

**计算公式**：CCI = (典型价格 - SMA) / (0.015 × 平均偏差)

**默认周期**：20

**用途**：
- 识别超买超卖
- 发现周期性转折点

---

#### Mass Index - 质量指数
**文件**：`mass_index.cj`

**特点**：
- 预测趋势反转
- 基于高低价差

**默认周期**：25

---

### 5. 特殊价格指标

#### Typical Price - 典型价格
**文件**：`typical_price.cj`

**计算公式**：典型价格 = (最高价 + 最低价 + 收盘价) / 3

**用途**：
- 作为其他指标的输入
- 更准确反映价格水平

---

#### Weighted Close - 加权收盘价
**文件**：`weighted_close.cj`

**计算公式**：加权收盘价 = (最高价 + 最低价 + 2×收盘价) / 4

**用途**：
- 收盘价权重更高
- 常用于计算其他指标

---

### 6. 辅助计算指标

#### Moving Sum - 移动求和
**文件**：`moving_sum.cj`

**功能**：计算指定周期内的总和

**默认周期**：30

---

#### Moving Max - 移动最大值
**文件**：`moving_max.cj`

**功能**：计算指定周期内的最大值

**默认周期**：30

---

#### Moving Min - 移动最小值
**文件**：`moving_min.cj`

**功能**：计算指定周期内的最小值

**默认周期**：30

---

#### MLR (Moving Linear Regression) - 移动线性回归
**文件**：`mlr.cj`

**功能**：计算线性回归线

**默认周期**：30

---

#### MLS (Moving Linear Regression Slope) - 移动线性回归斜率
**文件**：`mls.cj`

**功能**：计算线性回归斜率

**默认周期**：30

---

### 7. 其他指标

#### BOP (Balance of Power) - 力量平衡
**文件**：`bop.cj`

**计算公式**：BOP = (收盘价 - 开盘价) / (最高价 - 最低价)

**用途**：
- 衡量买卖力量
- 识别趋势强度

---

#### KDJ - 随机指标
**文件**：`kdj.cj`

**组成**：
- K 线：快速随机值
- D 线：K 线的移动平均
- J 线：K 和 D 的偏离

**默认参数**：
- K 周期：9
- D 周期：3
- J 倍数：3

---

## 使用示例

### 示例 1：计算简单移动平均线

```cangjie
import indicator4cj.trend.*
import indicator4cj.helper.*

// 价格数据
let prices = [10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0]
let iter = prices.iterator()

// 计算 5 周期 SMA
let sma = Sma(5)
let result = sma.compute(iter)

// 输出结果（前 4 个为 None，因为需要预热）
for (v in result) {
    if (let Some(value) <- v) {
        println(value)  // 从第 5 个数据开始输出
    }
}
```

### 示例 2：MACD 指标

```cangjie
import indicator4cj.trend.*

let prices = loadPriceData()  // 加载价格数据

// 计算 MACD
let macd = Macd()
let (macdLine, signalLine, histogram) = macd.compute(prices.iterator())

// 分析结果
for ((m, s, h) in zip3(macdLine, signalLine, histogram)) {
    if (let Some(macdVal) <- m,
        let Some(signalVal) <- s,
        let Some(histVal) <- h) {
        println("MACD: ${macdVal}, Signal: ${signalVal}, Histogram: ${histVal}")

        // 金叉信号
        if (histVal > 0) {
            println("买入信号")
        }
    }
}
```

### 示例 3：布林带交易策略

```cangjie
import indicator4cj.trend.*
import indicator4cj.volatility.*

let prices = loadPriceData()

// 计算布林带
let bb = BollingerBands(20, 2.0)
let (upper, middle, lower) = bb.compute(prices.iterator())

// 简单的交易策略
for ((u, m, l, price) in zip4(upper, middle, lower, prices)) {
    if (let Some(upperVal) <- u,
        let Some(middleVal) <- m,
        let Some(lowerVal) <- l) {

        // 价格触及下轨 - 超卖信号
        if (price <= lowerVal) {
            println("超卖信号，考虑买入")
        }
        // 价格触及上轨 - 超买信号
        else if (price >= upperVal) {
            println("超买信号，考虑卖出")
        }
    }
}
```

### 示例 4：多指标组合分析

```cangjie
import indicator4cj.trend.*

let prices = loadPriceData()

// 同时计算多个指标
let sma20 = Sma(20).compute(prices.iterator())
let ema12 = Ema(12).compute(prices.iterator())
let macd = Macd().compute(prices.iterator())

// 综合分析
for ((sma, ema) in zip(sma20, ema12)) {
    if (let Some(smaVal) <- sma,
        let Some(emaVal) <- ema) {

        // 多头排列：EMA > SMA
        if (emaVal > smaVal) {
            println("上升趋势")
        }
        // 空头排列：EMA < SMA
        else if (emaVal < smaVal) {
            println("下降趋势")
        }
    }
}
```

## 注意事项

1. **预热期（Idle Period）**：所有指标都有预热期，前 N-1 个数据点不会产生有效输出
2. **参数选择**：默认参数仅供参考，应根据不同市场和品种调整
3. **滞后性**：移动平均线类指标具有滞后性，不适合捕捉短期转折点
4. **组合使用**：建议多个指标组合使用，避免单一指标的假信号
5. **趋势识别**：趋势类指标在震荡市场中效果较差，应配合震荡类指标使用

## 依赖关系

- **indicator4cj.helper** - 辅助函数和流式处理工具

## 版本历史

### v1.0.0 (2024)
- 初始版本
- 实现所有主流趋势指标
- 支持流式计算
- 提供完整的测试覆盖
