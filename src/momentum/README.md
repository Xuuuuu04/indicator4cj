# indicator4cj.momentum - 动量指标包

## 版本
v1.0.0

## 包简介
`momentum` 包提供了衡量价格变化速度与强度的动量指标，用于识别超买超卖状态和潜在的价格反转点。这些指标主要分析价格变动的速率和幅度，帮助交易者判断市场的强弱。

## 核心指标列表

### 1. RSI 家族

#### RSI (Relative Strength Index) - 相对强弱指标
**文件**：`rsi.cj`

**计算公式**：RSI = 100 - 100 / (1 + RS)，其中 RS = 平均涨幅 / 平均跌幅

**默认周期**：14

**取值范围**：0-100

**用途**：
- RSI > 70：超买区域，可能回调
- RSI < 30：超卖区域，可能反弹
- 背离信号：价格创新高但 RSI 未创新高（顶背离）

**特点**：
- 衡量价格变动的速度和变化
- 识别超买超卖状态
- 预警潜在反转

---

#### Stochastic RSI - 随机相对强弱指标
**文件**：`stochastic_rsi.cj`

**计算公式**：StochRSI = (RSI - RSI最低值) / (RSI最高值 - RSI最低值)

**默认参数**：
- RSI 周期：14
- Stoch 周期：14
- 平滑周期：3

**取值范围**：0-100

**特点**：
- 比 RSI 更敏感
- 产生更多交易信号
- 适合短线交易

---

### 2. 随机指标系列

#### Stochastic Oscillator - 随机振荡器
**文件**：`stochastic_oscillator.cj`

**计算公式**：
- %K = 100 × (收盘价 - N周期最低价) / (N周期最高价 - N周期最低价)
- %D = %K 的 M 周期简单移动平均

**默认参数**：
- K 周期：14
- D 周期：3

**取值范围**：0-100

**用途**：
- %K > %D：买入信号
- %K < %D：卖出信号
- %K > 80：超买区域
- %K < 20：超卖区域

**特点**：
- 比较收盘价与价格区间的关系
- 产生超买超卖信号
- 适合震荡市场

---

### 3. 振荡器指标

#### Awesome Oscillator (AO) - 动量振荡器
**文件**：`awesome_oscillator.cj`

**计算公式**：AO = SMA(最高价+最低价)/2, 5周期 - SMA(最高价+最低价)/2, 34周期

**特点**：
- 衡量市场动量
- 识别趋势变化
- 零轴交叉信号

**交易信号**：
- AO 上穿零轴：买入信号
- AO 下穿零轴：卖出信号
- 碗底/碟顶形态

---

#### Chaikin Oscillator - 佳庆振荡器
**文件**：`chaikin_oscillator.cj`

**计算公式**：CO = EMA(ADL, 3) - EMA(ADL, 10)，其中 ADL 为累积派发线

**特点**：
- 结合价格和成交量
- 衡量资金流向
- 预警趋势变化

---

#### Williams %R (威廉指标)
**文件**：`williams_r.cj`

**计算公式**：%R = -100 × (N周期最高价 - 当前收盘价) / (N周期最高价 - N周期最低价)

**默认周期**：14

**取值范围**：-100 到 0

**用途**：
- %R > -20：超买区域
- %R < -80：超卖区域
- 与 RSI 类似但更敏感

**特点**：
- 反向指标（值越小越超买）
- 由 Larry Williams 开发
- 适合短期交易

---

### 4. 其他动量指标

#### Momentum - 动量指标
**文件**：`momentum.cj`

**计算公式**：Momentum = 当前价格 - N周期前价格

**默认周期**：10

**用途**：
- 衡量价格变化速度
- 识别趋势强度
- 零轴上下运动

---

#### PPO (Percentage Price Oscillator) - 百分比价格振荡器
**文件**：`ppo.cj`

**计算公式**：PPO = (EMA(快线) - EMA(慢线)) / EMA(慢线) × 100

**默认参数**：
- 快线周期：12
- 慢线周期：26

**特点**：
- 与 MACD 类似，但使用百分比
- 便于不同价格水平比较
- 零轴交叉信号

---

#### PVO (Percentage Volume Oscillator) - 百分比成交量振荡器
**文件**：`pvo.cj`

**计算公式**：PVO = (EMA(成交量, 快线) - EMA(成交量, 慢线)) / EMA(成交量, 慢线) × 100

**默认参数**：
- 快线周期：12
- 慢线周期：26

**特点**：
- 衡量成交量变化率
- 确认价格趋势
- 识别成交量异常

---

#### Qstick - 量能指标
**文件**：`qstick.cj`

**计算公式**：Qstick = SMA(收盘价 - 开盘价, N)

**默认周期**：N（通常为 8-20）

**用途**：
- 衡量买卖压力
- 正值表示买方力量强
- 负值表示卖方力量强

**特点**：
- 基于 K 线实体
- 识别市场情绪
- 简单直观

---

### 5. 复合指标

#### Ichimoku Cloud (一目均衡表)
**文件**：`ichimoku_cloud.cj`

**组成部分**：
- **转换线 (Tenkan-sen)**：(N周期最高价 + N周期最低价) / 2，默认 N=9
- **基准线 (Kijun-sen)**：(M周期最高价 + M周期最低价) / 2，默认 M=26
- **先行带 A (Senkou Span A)**：(转换线 + 基准线) / 2
- **先行带 B (Senkou Span B)**：(S周期最高价 + S周期最低价) / 2，默认 S=52
- **滞后带 (Chikou Span)**：当前收盘价向后平移 M 周期

**用途**：
- 价格在云带上方：上升趋势
- 价格在云带下方：下降趋势
- 转换线上穿基准线：买入信号
- 转换线下穿基准线：卖出信号

**特点**：
- 日本技术分析工具
- 提供全面的趋势分析
- 支撑阻力识别

---

#### Pring's Special K (普林特种 K)
**文件**：`prings_special_k.cj`

**计算公式**：多个不同周期的 ROC 指标的加权平均

**特点**：
- 由 Martin Pring 开发
- 识别长期趋势
- 过滤短期噪音
- 产生明确的买卖信号

---

## 使用示例

### 示例 1：RSI 超买超卖策略

```cangjie
import indicator4cj.momentum.*

let prices = loadPriceData()

// 计算 RSI
let rsi = Rsi(14)
let rsiValues = rsi.compute(prices.iterator())

// 简单的超买超卖策略
for (rsiVal in rsiValues) {
    if (let Some(val) <- rsiVal) {
        if (val > 70) {
            println("超买信号：${val}")
        } else if (val < 30) {
            println("超卖信号：${val}")
        }
    }
}
```

### 示例 2：随机振荡器交易策略

```cangjie
import indicator4cj.momentum.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()

// 计算随机振荡器
let stoch = StochasticOscillator(14, 3)
let (kLine, dLine) = stoch.compute(highs.iterator(), lows.iterator(), closes.iterator())

// 交叉信号策略
for ((k, d) in zip(kLine, dLine)) {
    if (let Some(kVal) <- k,
        let Some(dVal) <- d) {

        // 金叉：K 线上穿 D 线
        if (kVal > dVal && kVal < 80) {
            println("买入信号：K=${kVal}, D=${dVal}")
        }
        // 死叉：K 线下穿 D 线
        else if (kVal < dVal && kVal > 20) {
            println("卖出信号：K=${kVal}, D=${dVal}")
        }
    }
}
```

### 示例 3：Williams %R 背离分析

```cangjie
import indicator4cj.momentum.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()

// 计算 Williams %R
let williamsR = WilliamsR(14)
let wrValues = williamsR.compute(highs.iterator(), lows.iterator(), closes.iterator())

// 分析超买超卖
for (wr in wrValues) {
    if (let Some(val) <- wr) {
        if (val > -20) {
            println("超买区域：${val}")
        } else if (val < -80) {
            println("超卖区域：${val}")
        }
    }
}
```

### 示例 4：动量指标组合

```cangjie
import indicator4cj.momentum.*
import indicator4cj.trend.*

let closes = loadClosePrices()

// 同时计算 RSI 和 MACD
let rsi = Rsi(14).compute(closes.iterator())
let macd = Macd().compute(closes.iterator())

// 组合分析
for ((rsiVal, macdVal) in zip(rsi, macdVal)) {
    if (let Some(r) <- rsiVal,
        let Some(m) <- macdVal) {

        // 强势信号：RSI > 50 且 MACD > 0
        if (r > 50 && m > 0) {
            println("强势上涨")
        }
        // 弱势信号：RSI < 50 且 MACD < 0
        else if (r < 50 && m < 0) {
            println("弱势下跌")
        }
    }
}
```

### 示例 5：一目均衡表分析

```cangjie
import indicator4cj.momentum.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()

// 计算一目均衡表
let ichimoku = IchimokuCloud()
let (tenkan, kijun, senkouA, senkouB, chikou) =
    ichimoku.compute(highs.iterator(), lows.iterator(), closes.iterator())

// 分析趋势
for ((price, cloudTop, cloudBottom) in zip3(closes, senkouA, senkouB)) {
    if (let Some(p) <- price,
        let Some(top) <- cloudTop,
        let Some(bottom) <- cloudBottom) {

        // 价格在云带上方
        if (p > top) {
            println("上升趋势")
        }
        // 价格在云带下方
        else if (p < bottom) {
            println("下降趋势")
        }
        // 价格在云带内部
        else {
            println("震荡市场")
        }
    }
}
```

## 注意事项

1. **参数敏感性**：动量指标对参数设置较为敏感，应根据市场特性调整
2. **超买超卖持续**：在强趋势中，指标可能长期处于超买或超卖区域
3. **背离信号**：背离信号是重要的预警，但可能提前或滞后
4. **假信号**：在震荡市场中容易产生假信号，应结合其他指标
5. **时间周期**：不同时间周期可能给出相反信号，应关注主要交易周期

## 典型应用场景

1. **日内交易**：使用 RSI(14) 或随机振荡器(14,3) 寻找短期反转点
2. **波段交易**：使用 PPO 或 Pring's Special K 捕捉中期趋势
3. **趋势确认**：使用 AO 或 Chaikin Oscillator 确认趋势强度
4. **背离分析**：RSI 或 Stochastic RSI 的背离信号预警趋势反转
5. **超买超卖**：Williams %R 或随机振荡器识别极端市场情绪

## 依赖关系

- **indicator4cj.helper** - 辅助函数和流式处理工具
- **indicator4cj.trend** - 移动平均线等趋势指标（部分动量指标依赖）

## 版本历史

### v1.0.0 (2024)
- 初始版本
- 实现所有主流动量指标
- 支持 RSI 家族指标
- 支持随机指标系列
- 提供完整的测试覆盖
