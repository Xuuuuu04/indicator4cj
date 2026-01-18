# indicator4cj.volume - 成交量指标包

## 版本
v1.0.0

## 包简介
`volume` 包提供了结合成交量分析价格趋势的指标。成交量是市场活跃度的直接体现，通过量价关系可以更准确地判断趋势的真实性和持续性。

## 核心指标列表

### 1. 累积/派发指标

#### OBV (On-Balance Volume) - 能量潮指标
**文件**：`obv.cj`

**计算公式**：
- 若收盘价 > 前收盘价：OBV = 前OBV + 成交量
- 若收盘价 < 前收盘价：OBV = 前OBV - 成交量
- 若收盘价 = 前收盘价：OBV = 前OBV

**特点**：
- 最经典的成交量指标
- 由 Joseph Granville 开发
- 反映资金流向

**交易信号**：
- OBV 上升：买方力量强
- OBV 下降：卖方力量强
- OBV 背离：价格创新高但 OBV 未创新高（顶背离）

---

#### AD (Accumulation/Distribution) - 累积派发线
**文件**：`ad.cj`

**计算公式**：
CLV = (收盘价 - 最低价) - (最高价 - 收盘价) / (最高价 - 最低价)
AD = 前AD + CLV × 成交量

**特点**：
- 考虑价格在日内的位置
- 比 OBV 更精确
- 由 Marc Chaikin 开发

**用途**：
- 确认趋势强度
- 识别背离信号
- 衡量资金累积/派发

---

#### CMF (Chaikin Money Flow) - 佳庆资金流
**文件**：`cmf.cj`

**计算公式**：
CMF = Sum(CLV × 成交量, N) / Sum(成交量, N)

**默认周期**：20

**取值范围**：-1 到 1

**用途**：
- CMF > 0：买方控制
- CMF < 0：卖方控制
- CMF > 0.25：强买入压力
- CMF < -0.25：强卖出压力

**特点**：
- 标准化的 AD 指标
- 便于比较不同时期
- 短期资金流向指标

---

### 2. 资金流量指标

#### MFI (Money Flow Index) - 资金流量指数
**文件**：`mfi.cj`

**计算公式**：
1. 典型价格 = (最高价 + 最低价 + 收盘价) / 3
2. 资金流量 = 典型价格 × 成交量
3. 资金比率 = 正资金流量 / 负资金流量
4. MFI = 100 - 100 / (1 + 资金比率)

**默认周期**：14

**取值范围**：0-100

**用途**：
- MFI > 80：超买区域
- MFI < 20：超卖区域
- 类似 RSI 但结合成交量

**特点**：
- 成交量加权的 RSI
- 识别市场强弱
- 由 Gene Quong 和 Avrum Soudack 开发

---

#### MFM (Money Flow Multiplier) - 资金流量乘数
**文件**：`mfm.cj`

**计算公式**：
MFM = ((收盘价 - 最低价) - (最高价 - 收盘价)) / (最高价 - 最低价)

**取值范围**：-1 到 1

**用途**：
- 计算资金流向
- CMF 的组成部分
- 衡量买卖压力

---

#### MFV (Money Flow Volume) - 资金流量量
**文件**：`mfv.cj`

**计算公式**：MFV = MFM × 成交量

**用途**：
- 计算资金流量
- CMF 的组成部分
- 衡量资金规模

---

### 3. 成交量趋势指标

#### NVI (Negative Volume Index) - 负量指标
**文件**：`nvi.cj**

**计算公式**：
- 若成交量 < 前成交量：NVI = 前NVI × (价格变化率)
- 若成交量 >= 前成交量：NVI = 前NVI

**特点**：
- 关注成交量下降的时期
- 识别"聪明钱"动向
- 由 Norman Fosback 开发

**用途**：
- NVI 上升：牛市信号
- NVI 下降：熊市信号
- 长期趋势指标

---

#### VPT (Volume Price Trend) - 量价趋势
**文件**：`vpt.cj`

**计算公式**：
VPT = 前VPT + 成交量 × (价格变化百分比)

**特点**：
- 结合价格变化和成交量
- 累积指标
- 识别趋势确认

**交易信号**：
- VPT 上升：量价齐升
- VPT 下降：量价齐跌
- VPT 背离：趋势反转预警

---

### 4. 价格加权指标

#### VWAP (Volume Weighted Average Price) - 成交量加权平均价
**文件**：`vwap.cj`

**计算公式**：
VWAP = Σ(典型价格 × 成交量) / Σ(成交量)

其中典型价格 = (最高价 + 最低价 + 收盘价) / 3

**特点**：
- 机构交易的重要参考
- 日内交易的基准价格
- 反映市场平均成本

**用途**：
- VWAP 之上：买方占优
- VWAP 之下：卖方占优
- 算法交易的基准

**应用场景**：
- 机构大单执行
- 日内交易
- 算法交易基准

---

### 5. 成交量动量指标

#### FI (Force Index) - 力量指数
**文件**：`fi.cj`

**计算公式**：
FI = (当前收盘 - 前收盘) × 成交量

**特点**：
- 由 Alexander Elder 开发
- 衡量买卖力量
- 可使用 EMA 平滑

**用途**：
- FI > 0：买方力量强
- FI < 0：卖方力量强
- FI 的绝对值反映力量大小

**参数**：
- 原始 FI：使用 1 周期
- 平滑 FI：使用 13 周期 EMA

---

#### EMV (Ease of Movement) - 简易运动指标
**文件**：`emv.cj`

**计算公式**：
DM = (最高价 + 最低价) / 2 - (前最高 + 前最低) / 2
EMV = DM / 成交量 × 10000

**特点**：
- 衡量价格变动的难易程度
- 由 Richard W. Arms Jr. 开发
- 考虑价格振幅和成交量

**用途**：
- EMV > 0：价格容易上涨
- EMV < 0：价格容易下跌
- EMV 围绕零轴波动

---

## 使用示例

### 示例 1：OBV 趋势确认

```cangjie
import indicator4cj.volume.*

let closes = loadClosePrices()
let volumes = loadVolumes()

// 计算 OBV
let obv = Obv()
let obvValues = obv.compute(closes.iterator(), volumes.iterator())

// 趋势确认策略
for ((obv, price) in zip(obvValues, closes)) {
    if (let Some(obvVal) <- obv) {
        // OBV 上升确认价格上涨
        if (obvVal > 0) {
            println("资金流入，价格可能上涨")
        }
        // OBV 下降表明价格可能下跌
        else if (obvVal < 0) {
            println("资金流出，价格可能下跌")
        }
    }
}
```

### 示例 2：MFI 超买超卖

```cangjie
import indicator4cj.volume.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()
let volumes = loadVolumes()

// 计算 MFI
let mfi = Mfi(14)
let mfiValues = mfi.compute(highs.iterator(), lows.iterator(), closes.iterator(), volumes.iterator())

// 超买超卖策略
for (mfi in mfiValues) {
    if (let Some(val) <- mfi) {
        if (val > 80) {
            println("超买区域：${val}")
        } else if (val < 20) {
            println("超卖区域：${val}")
        }
    }
}
```

### 示例 3：VWAP 日内交易

```cangjie
import indicator4cj.volume.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()
let volumes = loadVolumes()

// 计算 VWAP
let vwap = Vwap()
let vwapValues = vwap.compute(highs.iterator(), lows.iterator(), closes.iterator(), volumes.iterator())

// 日内交易策略
for ((vwap, price) in zip(vwapValues, closes)) {
    if (let Some(vwapVal) <- vwap) {
        if (price > vwapVal) {
            println("价格高于 VWAP，买方占优，考虑买入")
        } else if (price < vwapVal) {
            println("价格低于 VWAP，卖方占优，考虑卖出")
        }
    }
}
```

### 示例 4：CMF 资金流向分析

```cangjie
import indicator4cj.volume.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()
let volumes = loadVolumes()

// 计算 CMF
let cmf = Cmf(20)
let cmfValues = cmf.compute(highs.iterator(), lows.iterator(), closes.iterator(), volumes.iterator())

// 资金流向策略
for (cmf in cmfValues) {
    if (let Some(val) <- cmf) {
        if (val > 0.25) {
            println("强买入压力：${val}")
        } else if (val > 0) {
            println("买方控制：${val}")
        } else if (val < -0.25) {
            println("强卖出压力：${val}")
        } else {
            println("卖方控制：${val}")
        }
    }
}
```

### 示例 5：多成交量指标组合

```cangjie
import indicator4cj.volume.*
import indicator4cj.trend.*

let highs = loadHighPrices()
let lows = loadLowPrices()
let closes = loadClosePrices()
let volumes = loadVolumes()

// 同时计算多个成交量指标
let obv = Obv().compute(closes.iterator(), volumes.iterator())
let mfi = Mfi(14).compute(highs.iterator(), lows.iterator(), closes.iterator(), volumes.iterator())
let ad = Ad().compute(highs.iterator(), lows.iterator(), closes.iterator(), volumes.iterator())

// 综合分析
for ((obv, mfi, ad, price) in zip4(obv, mfi, ad, closes)) {
    if (let Some(obvVal) <- obv,
        let Some(mfiVal) <- mfi,
        let Some(adVal) <- ad) {

        // 强势信号：OBV上升，MFI>50，AD上升
        if (obvVal > 0 && mfiVal > 50 && adVal > 0) {
            println("强势上涨，资金持续流入")
        }
        // 弱势信号：OBV下降，MFI<50，AD下降
        else if (obvVal < 0 && mfiVal < 50 && adVal < 0) {
            println("弱势下跌，资金持续流出")
        }
    }
}
```

## 注意事项

1. **成交量真实性**：某些市场成交量可能被操纵，需谨慎分析
2. **时间周期**：不同时间周期的成交量特征不同
3. **背离信号**：量价背离是重要的预警信号
4. **极端值**：成交量极端放大或缩小都有特殊意义
5. **结合价格**：成交量指标必须结合价格走势分析

## 典型应用场景

1. **趋势确认**：OBV 或 AD 确认价格趋势的真实性
2. **日内交易**：VWAP 作为日内交易的基准价格
3. **资金流向**：CMF 或 MFI 判断短期资金流向
4. **背离分析**：成交量与价格的背离预警趋势反转
5. **机构行为**：NVI 识别"聪明钱"的动向

## 依赖关系

- **indicator4cj.helper** - 辅助函数和流式处理工具
- **indicator4cj.trend** - 移动平均线等趋势指标

## 版本历史

### v1.0.0 (2024)
- 初始版本
- 实现所有主流成交量指标
- 支持累积/派发指标
- 支持资金流量指标
- 提供完整的测试覆盖
