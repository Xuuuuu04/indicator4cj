# indicator4cj API 参考手册

> **版本**: v1.0.0 正式版
> **仓颉版本**: 1.0.4
> **更新日期**: 2026-01-27

本文档提供 `indicator4cj` 库的主要 API 参考手册（以当前仓库代码为准，文档可能会随版本演进而滞后）。完整迁移对比与限制说明见 [migration_status.md](./migration_status.md)。

---

## 目录

1. [核心数据模型](#1-核心数据模型)
2. [流式计算辅助函数](#2-流式计算辅助函数)
3. [技术指标 API](#3-技术指标-api)
4. [交易策略 API](#4-交易策略-api)
5. [回测框架 API](#5-回测框架-api)
6. [常量定义](#6-常量定义)

---

## 1. 核心数据模型

### 1.1 Snapshot 类

标准行情快照数据结构，表示某个特定时间点的 OHLCV 数据。

**包路径**: `indicator4cj.asset.Snapshot`

**字段定义**:

| 字段名 | 类型 | 说明 |
|-------|------|------|
| `date` | `DateTime` | 日期时间戳 |
| `open` | `Float64` | 开盘价 |
| `high` | `Float64` | 最高价 |
| `low` | `Float64` | 最低价 |
| `close` | `Float64` | 收盘价 |
| `adjClose` | `Float64` | 调整后收盘价（考虑分红、拆股等） |
| `volume` | `Float64` | 成交量 |

**构造函数**:

```cangjie
public init()
public init(
    date: DateTime,
    open: Float64,
    high: Float64,
    low: Float64,
    close: Float64,
    adjClose: Float64,
    volume: Float64
)
```

**方法**:

```cangjie
public func toString(): String  // 实现 ToString 接口
```

**使用示例**:

```cangjie
let snap = Snapshot(
    date = DateTime(2024, 1, 1),
    open = 100.0,
    high = 105.0,
    low = 98.0,
    close = 103.0,
    adjClose = 103.0,
    volume = 1000000.0
)
```

---

### 1.2 Repository 接口

资产数据仓储接口，提供资产数据的查询和管理功能。

**包路径**: `indicator4cj.asset.Repository`

**方法签名**:

```cangjie
/**
 * assets 返回所有资产名称列表
 * @return 资产名称列表
 */
func assets(): ArrayList<String>

/**
 * get 获取指定资产的全部快照数据
 * @param name 资产名称
 * @return 快照数据迭代器的 Option，资产不存在时返回 None
 */
func get(name: String): Option<Iterator<Snapshot>>

/**
 * getSince 获取指定资产从指定日期开始的快照数据
 * @param name 资产名称
 * @param date 起始日期
 * @return 快照数据迭代器
 * @throws 当资产不存在时抛出异常
 */
func getSince(name: String, date: DateTime): Iterator<Snapshot>

/**
 * lastDate 返回指定资产的最新日期
 * @param name 资产名称
 * @return 最新日期的 Option，资产不存在或为空时返回 None
 */
func lastDate(name: String): Option<DateTime>

/**
 * append 向指定资产追加快照数据
 * @param name 资产名称
 * @param snapshots 快照数据迭代器
 * @throws 当追加失败时抛出异常
 */
func append(name: String, snapshots: Iterator<Snapshot>): Unit
```

---

### 1.3 Repository 实现类

#### 1.3.1 FileSystemRepository

基于文件系统的仓储实现，数据以 CSV 格式存储。

**包路径**: `indicator4cj.asset.FileSystemRepository`

**构造函数**:

```cangjie
/**
 * 创建文件系统仓储
 * @param root 数据根目录路径
 */
public init(root: String)
```

#### 1.3.2 InMemoryRepository

基于内存的仓储实现，适用于测试和快速原型。

**包路径**: `indicator4cj.asset.InMemoryRepository`

**构造函数**:

```cangjie
public init()
```

#### 1.3.3 SQLRepository

基于 SQL 数据库的仓储实现（依赖 `std.database.sql`），支持注入 Driver 或通过 DriverManager 按名称获取。

**包路径**: `indicator4cj.asset.SQLRepository`

**构造函数**:

```cangjie
public init(driver: Driver, connectionString: String, dialect: SQLRepositoryDialect)
public init(driver: Driver, connectionString: String, dialect: SQLRepositoryDialect, opts: Array<(String, String)>)
public init(driverName: String, connectionString: String, dialect: SQLRepositoryDialect)
public init(driverName: String, connectionString: String, dialect: SQLRepositoryDialect, opts: Array<(String, String)>)
```

#### 1.3.4 TiingoRepository

基于 Tiingo API 的在线数据仓储。

**包路径**: `indicator4cj.asset.TiingoRepository`

**构造函数**:

```cangjie
/**
 * 创建 Tiingo API 仓储
 * @param apiKey Tiingo API 密钥
 */
public init(apiKey: String)
```

---

### 1.4 Action 枚举

交易动作枚举，表示买入、持有或卖出操作。

**包路径**: `indicator4cj.strategy.Action`

**枚举值**:

| 值 | 说明 |
|---|------|
| `BUY` | 买入信号 |
| `SELL` | 卖出信号 |
| `HOLD` | 持有（无操作） |

**方法**:

```cangjie
public func toString(): String
```

---

### 1.5 Outcome 类

交易结果类，表示单次交易的盈亏情况。

**包路径**: `indicator4cj.strategy.Outcome`

**字段定义**:

| 字段名 | 类型 | 说明 |
|-------|------|------|
| `entryDate` | `DateTime` | 入场日期 |
| `entryPrice` | `Float64` | 入场价格 |
| `exitDate` | `DateTime` | 离场日期 |
| `exitPrice` | `Float64` | 离场价格 |
| `amount` | `Float64` | 交易数量 |
| `profitLoss` | `Float64` | 盈亏金额 |

---

### 1.6 Result 类

回测结果类，包含完整的统计信息。

**包路径**: `indicator4cj.strategy.Result`

**字段定义**:

| 字段名 | 类型 | 说明 |
|-------|------|------|
| `assetName` | `String` | 资产名称 |
| `strategyName` | `String` | 策略名称 |
| `actions` | `Array<Action>` | 动作序列 |
| `outcomes` | `Array<Outcome>` | 交易结果序列 |
| `equity` | `Float64` | 最终权益 |
| `buyAndHoldEquity` | `Float64` | 买入持有策略的最终权益 |
| `percentage` | `Float64` | 收益率百分比 |
| `annualisedReturn` | `Float64` | 年化收益率 |
| `annualisedBuyAndHoldReturn` | `Float64` | 买入持有年化收益率 |
| `totalTrades` | `Int64` | 总交易次数 |
| `profitTrades` | `Int64` | 盈利交易次数 |
| `lossTrades` | `Int64` | 亏损交易次数 |
| `profitLossRatio` | `Float64` | 盈亏比 |
| `maxDrawdown` | `Float64` | 最大回撤 |

---

## 2. 流式计算辅助函数

流式计算辅助函数位于 `indicator4cj.helper` 包中，提供基于 `Iterator<T>` 的高阶函数。

### 2.1 基础算子

#### 2.1.1 Duplicate

一分多流转换，将一个迭代器复制为多个独立的迭代器。

**函数签名**:

```cangjie
/**
 * 将源迭代器复制为 n 份
 * @param iter 源迭代器
 * @param n 复制份数
 * @return 迭代器列表
 */
public func duplicate<T>(iter: Iterator<T>, n: Int64): ArrayList<Iterator<T>>
```

**使用示例**:

```cangjie
let copies = duplicate(sourceData, 3)
let sma = Sma(20).compute(copies[0])
let ema = Ema(20).compute(copies[1])
let wma = Wma(20).compute(copies[2])
```

---

#### 2.1.2 Map

映射转换函数。

**函数签名**:

```cangjie
/**
 * 对迭代器中的每个元素应用映射函数
 * @param iter 源迭代器
 * @param mapper 映射函数
 * @return 转换后的迭代器
 */
public func map<F, T>(iter: Iterator<F>, mapper: (F) -> T): Iterator<T>
```

---

#### 2.1.3 Apply

原地应用转换函数。

**函数签名**:

```cangjie
/**
 * 对迭代器中的每个元素原地应用转换
 * @param iter 源迭代器
 * @param mapper 转换函数
 * @return 转换后的迭代器
 */
public func apply<T>(iter: Iterator<T>, mapper: (T) -> T): Iterator<T>
```

---

#### 2.1.4 Shift

时间序列位移函数。

**函数签名**:

```cangjie
/**
 * 将迭代器向后位移 count 个位置，空位用 fill 填充
 * @param iter 源迭代器
 * @param count 位移数量
 * @param fill 填充值
 * @return 位移后的迭代器
 */
public func shift<T>(iter: Iterator<T>, count: Int64, fill: T): Iterator<T>
```

---

#### 2.1.5 Skip

跳过前 N 项。

**函数签名**:

```cangjie
/**
 * 跳过迭代器的前 count 项
 * @param iter 源迭代器
 * @param count 跳过数量
 * @return 跳过后的迭代器
 */
public func skip<T>(iter: Iterator<T>, count: Int64): Iterator<T>
```

---

#### 2.1.6 Filter

条件过滤函数。

**函数签名**:

```cangjie
/**
 * 过滤迭代器中满足条件的元素
 * @param iter 源迭代器
 * @param predicate 谓词函数
 * @return 过滤后的迭代器
 */
public func filter<T>(iter: Iterator<T>, predicate: (T) -> Bool): Iterator<T>
```

---

### 2.2 数学与统计函数

#### 2.2.1 Abs

绝对值函数。

**函数签名**:

```cangjie
public func abs(iter: Iterator<Float64>): Iterator<Float64>
```

---

#### 2.2.2 Add / Subtract / Multiply / Divide

基本四则运算。

**函数签名**:

```cangjie
public func add(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>
public func subtract(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>
public func multiply(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>
public func divide(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>
```

---

#### 2.2.3 RoundDigits

保留小数位数。

**函数签名**:

```cangjie
/**
 * 保留 d 位小数
 * @param iter 源迭代器
 * @param d 小数位数
 * @return 舍入后的迭代器
 */
public func roundDigits(iter: Iterator<Float64>, d: Int64): Iterator<Float64>
```

---

#### 2.2.4 Sign

符号函数。

**函数签名**:

```cangjie
/**
 * 返回每个元素的符号（-1, 0, 1）
 * @param iter 源迭代器
 * @return 符号迭代器
 */
public func sign(iter: Iterator<Float64>): Iterator<Float64>
```

---

#### 2.2.5 Pow / Sqrt

幂运算和平方根。

**函数签名**:

```cangjie
public func pow(iter: Iterator<Float64>, exp: Float64): Iterator<Float64>
public func sqrt(iter: Iterator<Float64>): Iterator<Float64>
```

---

### 2.3 时间序列函数

#### 2.3.1 Change

变动值计算。

**函数签名**:

```cangjie
/**
 * 计算相邻元素的差值
 * @param iter 源迭代器
 * @return 差值迭代器
 */
public func change(iter: Iterator<Float64>): Iterator<Float64>
```

---

#### 2.3.2 ChangePercent

变动百分比计算。

**函数签名**:

```cangjie
public func changePercent(iter: Iterator<Float64>): Iterator<Float64>
```

---

#### 2.3.3 ChangeRatio

变动比率计算。

**函数签名**:

```cangjie
public func changeRatio(iter: Iterator<Float64>): Iterator<Float64>
```

---

### 2.4 极值函数

#### 2.4.1 Highest

最大值函数。

**函数签名**:

```cangjie
/**
 * 计算窗口内的最大值
 * @param iter 源迭代器
 * @param period 窗口大小
 * @return 最大值迭代器
 */
public func highest(iter: Iterator<Float64>, period: Int64): Iterator<Float64>
```

---

#### 2.4.2 Lowest

最小值函数。

**函数签名**:

```cangjie
public func lowest(iter: Iterator<Float64>, period: Int64): Iterator<Float64>
```

---

### 2.5 CSV 解析函数

#### 2.5.1 ParseCsv

解析 CSV 文件。

**函数签名**:

```cangjie
/**
 * 解析 CSV 文件并返回 Snapshot 迭代器
 * @param path CSV 文件路径
 * @param reverse 是否反转（从旧到新）
 * @return Snapshot 迭代器
 */
public func parseCsv(path: String, reverse: Bool): Iterator<Snapshot>
```

---

## 3. 技术指标 API

所有技术指标位于以下包中：
- `indicator4cj.trend.*` - 趋势指标
- `indicator4cj.momentum.*` - 动量指标
- `indicator4cj.volatility.*` - 波动率指标
- `indicator4cj.volume.*` - 成交量指标

### 3.1 趋势指标 (Trend Indicators) - 31个

| 指标名称 | 类名 | 参数 | 说明 |
|---------|------|------|------|
| 简单移动平均线 | `Sma` | `period: Int64` | Simple Moving Average |
| 指数移动平均线 | `Ema` | `period: Int64` | Exponential Moving Average |
| 加权移动平均线 | `Wma` | `period: Int64` | Weighted Moving Average |
| 赫尔移动平均线 | `Hma` | `period: Int64` | Hull Moving Average |
| 双指数移动平均线 | `Dema` | `period: Int64` | Double Exponential Moving Average |
| 三角移动平均线 | `Trima` | `period: Int64` | Triangular Moving Average |
| TEMA | `Tema` | `period: Int64` | Triple Exponential Moving Average |
| 考夫曼自适应移动平均 | `Kama` | `er: Int64, fast: Int64, slow: Int64` | Kaufman's Adaptive Moving Average |
| MACD | `Macd` | `p1: Int64, p2: Int64, p3: Int64` | Moving Average Convergence Divergence |
| 阿隆指标 | `Aroon` | `period: Int64` | Aroon Indicator |
| 顺势指标 | `Cci` | `period: Int64` | Commodity Channel Index |
| 力量均衡指标 | `Bop` | 无 | Balance of Power |
| 绝对价格振荡器 | `Apo` | `p1: Int64, p2: Int64` | Absolute Price Oscillator |
| 似钱振荡器 | `Dpo` | `period: Int64` | Detrended Price Oscillator |
| 包络线 | `Envelope` | `period: Int64, k: Float64` | Envelope |
| KDJ | `Kdj` | `p1: Int64, p2: Int64, p3: Int64` | Stochastic Oscillator (KDJ) |
| 质量指数 | `MassIndex` | `period: Int64` | Mass Index |
| 移动线性回归 | `Mlr` | `period: Int64` | Moving Linear Regression |
| 移动最小二乘 | `Mls` | `period: Int64` | Moving Least Squares |
| 移动最大值 | `MovingMax` | `period: Int64` | Moving Maximum |
| 移动最小值 | `MovingMin` | `period: Int64` | Moving Minimum |
| 移动求和 | `MovingSum` | `period: Int64` | Moving Sum |
| RMA | `Rma` | `period: Int64` | Running Moving Average |
| SMMA | `Smma` | `period: Int64` | Smoothed Moving Average |
| ROC | `Roc` | `period: Int64` | Rate of Change |
| TRIX | `TriX` | `period: Int64` | Triple Exponential Average |
| TSI | `Tsi` | `p1: Int64, p2: Int64` | True Strength Index |
| 典型价格 | `TypicalPrice` | 无 | Typical Price |
| VWMA | `Vwma` | `period: Int64` | Volume Weighted Moving Average |
| 加权收盘价 | `WeightedClose` | 无 | Weighted Close Price |
| 移动平均线 | `Ma` | `ma: MaType, period: Int64` | Generic Moving Average |

**通用方法**:

所有指标类都实现以下接口：

```cangjie
/**
 * 计算指标值
 * @param closePrices 收盘价迭代器
 * @return 指标值迭代器
 */
public func compute(closePrices: Iterator<Float64>): Iterator<Float64>

/**
 * 返回预热期长度
 * @return 预热期长度
 */
public func idlePeriod(): Int64
```

**使用示例**:

```cangjie
// 计算 20 周期简单移动平均线
let sma = Sma(20)
let values = sma.compute(closePrices)

// 计算 MACD (12, 26, 9)
let macd = Macd(12, 26, 9)
let (macdLine, signalLine, histogram) = macd.compute(closePrices)
```

---

### 3.2 动量指标 (Momentum Indicators) - 12个

| 指标名称 | 类名 | 参数 | 说明 |
|---------|------|------|------|
| 相对强弱指数 | `Rsi` | `period: Int64` | Relative Strength Index |
| 随机振荡指标 | `StochasticOscillator` | `period: Int64` | Stochastic Oscillator (%K, %D) |
| 随机RSI | `StochasticRsi` | `period: Int64` | Stochastic RSI |
| 动量振荡器 | `AwesomeOscillator` | 无 | Awesome Oscillator |
| 威廉指标 | `WilliamsR` | `period: Int64` | Williams %R |
| 动量 | `Momentum` | `period: Int64` | Momentum |
| 蔡金振荡器 | `ChaikinOscillator` | 无 | Chaikin Oscillator |
| 一目均衡表 | `IchimokuCloud` | 无 | Ichimoku Kinko Hyo |
| 百分比振荡器 | `Ppo` | `p1: Int64, p2: Int64` | Percentage Price Oscillator |
| 普林格特别K | `PringsSpecialK` | 无 | Pring's Special K |
| 成交量振荡器 | `Pvo` | `p1: Int64, p2: Int64` | Percentage Volume Oscillator |
| QStick | `Qstick` | `period: Int64` | QStick |

**使用示例**:

```cangjie
// 计算 14 周期 RSI
let rsi = Rsi(14)
let values = rsi.compute(closePrices)

// 计算随机振荡器
let stoch = StochasticOscillator(14)
let (k, d) = stoch.compute(highPrices, lowPrices, closePrices)
```

---

### 3.3 波动率指标 (Volatility Indicators) - 12个

| 指标名称 | 类名 | 参数 | 说明 |
|---------|------|------|------|
| 平均真实波幅 | `Atr` | `ma: MaType, period: Int64` | Average True Range |
| 布林带 | `BollingerBands` | `period: Int64, multiplier: Float64` | Bollinger Bands |
| 布林带宽度 | `BollingerBandWidth` | `period: Int64, multiplier: Float64` | Bollinger Band Width |
| %B | `PercentB` | `period: Int64, multiplier: Float64` | %B Indicator |
| 肯特纳通道 | `KeltnerChannel` | `ma: MaType, period: Int64, multiplier: Float64` | Keltner Channel |
| 唐奇安通道 | `DonchianChannel` | `period: Int64` | Donchian Channel |
| 吊灯止损 | `ChandelierExit` | `period: Int64, multiplier: Float64` | Chandelier Exit |
| 移动标准差 | `MovingStd` | `period: Int64` | Moving Standard Deviation |
| 加速度带 | `AccelerationBands` | `period: Int64` | Acceleration Bands |
| 极速振荡器 | `Po` | `period: Int64` | Price Oscillator |
| 超级趋势 | `SuperTrend` | `period: Int64, multiplier: Float64` | SuperTrend |
| 溃疡指数 | `UlcerIndex` | `period: Int64` | Ulcer Index |

**使用示例**:

```cangjie
// 计算布林带 (20, 2.0)
let bb = BollingerBands(20, 2.0)
let (middle, upper, lower) = bb.compute(closePrices)

// 计算超级趋势 (10, 3.0)
let st = SuperTrend(10, 3.0)
let (trend, values) = st.compute(highPrices, lowPrices, closePrices)
```

---

### 3.4 成交量指标 (Volume Indicators) - 11个

| 指标名称 | 类名 | 参数 | 说明 |
|---------|------|------|------|
| 能量潮 | `Obv` | 无 | On Balance Volume |
| 资金流量指标 | `Mfi` | `period: Int64` | Money Flow Index |
| 负成交量指数 | `Nvi` | `initial: Float64` | Negative Volume Index |
| 成交量加权平均价 | `Vwap` | 无 | Volume Weighted Average Price |
| 累积/派发线 | `Ad` | 无 | Accumulation/Distribution Line |
| 蔡金资金流量 | `Cmf` | `period: Int64` | Chaikin Money Flow |
| 简易波动指标 | `Emv` | 无 | Ease of Movement |
| 力量指数 | `ForceIndex` | `period: Int64` | Force Index |
| 资金流量 | `Mfm` | 无 | Money Flow Multiplier |
| 资金流量值 | `Mfv` | 无 | Money Flow Volume |
| 成交量趋势 | `Vpt` | 无 | Volume Price Trend |

**使用示例**:

```cangjie
// 计算能量潮
let obv = Obv()
let values = obv.compute(closePrices, volumes)

// 计算资金流量指标
let mfi = Mfi(14)
let values = mfi.compute(highPrices, lowPrices, closePrices, volumes)
```

---

## 4. 交易策略 API

所有交易策略位于 `indicator4cj.strategy` 包及其子包中。

### 4.1 核心 Strategy 接口

```cangjie
public interface Strategy {
    /**
     * name 返回策略名称
     * @return 策略名称
     */
    func name(): String

    /**
     * compute 计算交易动作序列
     * @param snapshots 资产快照迭代器
     * @return 动作迭代器
     */
    func compute(snapshots: Iterator<Snapshot>): Iterator<Action>

    /**
     * report 生成策略报告
     * @param snapshots 资产快照迭代器
     * @return 策略报告
     */
    func report(snapshots: Iterator<Snapshot>): Report
}
```

---

### 4.2 趋势策略 (Trend Strategies) - 19个

| 策略名称 | 类名 | 参数 |
|---------|------|------|
| 吸鱼策略 | `AlligatorStrategy` | 无 |
| APO 策略 | `ApoStrategy` | 无 |
| Aroon 策略 | `AroonStrategy` | 无 |
| BOP 策略 | `BopStrategy` | 无 |
| CCI 策略 | `CciStrategy` | 无 |
| DEMA 策略 | `DemaStrategy` | 无 |
| 包络线策略 | `EnvelopeStrategy` | 无 |
| 金叉策略 | `GoldenCrossStrategy` | 无 |
| KAMA 策略 | `KamaStrategy` | 无 |
| KDJ 策略 | `KdjStrategy` | 无 |
| MACD 策略 | `MacdStrategy` | 无 |
| QStick 策略 | `QstickStrategy` | 无 |
| SMMA 策略 | `SmmaStrategy` | 无 |
| TRIMA 策略 | `TrimaStrategy` | 无 |
| 三重移动平均交叉策略 | `TripleMovingAverageCrossoverStrategy` | 无 |
| 三重 RSI 策略 | `TripleRsiStrategy` | 无 |
| TRIX 策略 | `TriXStrategy` | 无 |
| TSI 策略 | `TsiStrategy` | 无 |
| VWMA 策略 | `VwmaStrategy` | 无 |

---

### 4.3 动量策略 (Momentum Strategies) - 5个

| 策略名称 | 类名 | 参数 |
|---------|------|------|
| 动量振荡器策略 | `AwesomeOscillatorStrategy` | 无 |
| 动量策略 | `MomentumStrategy` | `period: Int64` |
| RSI 策略 | `RsiStrategy` | 无 |
| 随机 RSI 策略 | `StochasticRsiStrategy` | 无 |
| 三重 RSI 策略 | `TripleRsiStrategy` | 无 |

---

### 4.4 波动率策略 (Volatility Strategies) - 3个

| 策略名称 | 类名 | 参数 |
|---------|------|------|
| 布林带策略 | `BollingerBandsStrategy` | 无 |
| %B 和 MFI 策略 | `PercentBAndMfiStrategy` | 无 |
| 超级趋势策略 | `SuperTrendStrategy` | 无 |

---

### 4.5 成交量策略 (Volume Strategies) - 4个

| 策略名称 | 类名 | 参数 |
|---------|------|------|
| 蔡金资金流量策略 | `ChaikinMoneyFlowStrategy` | 无 |
| 简易波动策略 | `EaseOfMovementStrategy` | 无 |
| 力量指数策略 | `ForceIndexStrategy` | 无 |
| 负成交量指数策略 | `NegativeVolumeIndexStrategy` | 无 |

---

### 4.6 基础策略

| 策略名称 | 类名 | 说明 |
|---------|------|------|
| 买入持有策略 | `BuyAndHoldStrategy` | 简单的买入持有策略 |
| 加权收盘价策略 | `WeightedCloseStrategy` | 基于加权收盘价的策略 |
| 加权平均价策略 | `WeightedAveragePriceStrategy` | 基于 VWAP 的策略 |

---

### 4.7 装饰器策略 (Decorator Strategies)

装饰器策略用于为现有策略添加额外功能。

| 装饰器 | 类名 | 参数 | 说明 |
|-------|------|------|------|
| 止损策略 | `StopLossStrategy` | `base: Strategy, percentage: Float64` | 当亏损达到指定百分比时平仓 |
| 无损策略 | `NoLossStrategy` | `base: Strategy` | 仅在盈利时平仓 |
| 反向策略 | `InverseStrategy` | `base: Strategy` | 反转所有买卖信号 |

**使用示例**:

```cangjie
// 创建基础策略
let base = RsiStrategy()

// 添加 5% 止损
let withStopLoss = StopLossStrategy(base, 5.0)

// 反向信号（用于做空测试）
let inverted = InverseStrategy(withStopLoss)

// 计算动作
let actions = inverted.compute(snapshots)
```

---

### 4.8 逻辑组合策略

支持多个策略的逻辑组合。

| 组合方式 | 类名 | 参数 | 说明 |
|---------|------|------|------|
| 与策略 | `AndStrategy` | `name: String, strategies: ArrayList<Strategy>` | 所有子策略都同意时才买入 |
| 或策略 | `OrStrategy` | `name: String, strategies: ArrayList<Strategy>` | 任一子策略同意即买入 |
| 多数策略 | `MajorityStrategy` | `name: String, strategies: ArrayList<Strategy>` | 超过半数子策略同意即买入 |

**使用示例**:

```cangjie
// 与策略：所有子策略都同意时才买入
let and = AndStrategy("RSI + MACD", [RsiStrategy(), MacdStrategy()])

// 或策略：任一子策略同意即买入
let or = OrStrategy("RSI or Stochastic", [RsiStrategy(), StochasticOscillatorStrategy()])

// 多数策略
let majority = MajorityStrategy("Majority Vote", [
    RsiStrategy(),
    MacdStrategy(),
    BollingerBandsStrategy()
])
```

---

### 4.9 策略辅助函数

#### 4.9.1 actionSources

为多个策略创建独立的操作源。

**函数签名**:

```cangjie
public func actionSources(
    strategies: ArrayList<Strategy>,
    snapshots: Iterator<Snapshot>
): ArrayList<Iterator<Action>>
```

---

#### 4.9.2 computeWithOutcome

计算策略的操作序列及收益率。

**函数签名**:

```cangjie
public func computeWithOutcome(
    strategy: Strategy,
    snapshots: Iterator<Snapshot>
): (Iterator<Action>, Iterator<Outcome>)
```

---

#### 4.9.3 allStrategies

返回所有内置策略的列表。

**函数签名**:

```cangjie
public func allStrategies(): ArrayList<Strategy>
```

---

## 5. 回测框架 API

回测框架位于 `indicator4cj.backtest` 包中。

### 5.1 Backtest 类

回测引擎，支持单资产/多资产回测。

**包路径**: `indicator4cj.backtest.Backtest`

**字段定义**:

| 字段名 | 类型 | 说明 |
|-------|------|------|
| `repo` | `Repository` | 数据仓储 |
| `strategies` | `ArrayList<Strategy>` | 策略列表 |
| `reportFactory` | `ReportFactory` | 报告工厂 |
| `workers` | `Int64` | 并发资产数（默认 1） |
| `lastDays` | `Int64` | 追溯天数（默认 0，全部） |

**方法**:

```cangjie
/**
 * 运行回测
 * @return 异常的 Option，成功时返回 None
 */
public func run(): Option<Exception>
```

**使用示例**:

```cangjie
let repo = FileSystemRepository("data")
let strategies = [RsiStrategy(), MacdStrategy()]
let reportFactory = ReportFactory()

let backtest = Backtest(repo, strategies, reportFactory)
backtest.workers = 4  // 4 个并发资产
backtest.lastDays = 365  // 只回测最近一年

let error = backtest.run()
if (let Some(e) <- error) {
    println("回测失败: ${e.message}")
}
```

---

### 5.2 Report 接口

报告生成接口。

**包路径**: `indicator4cj.backtest.Report`

**方法**:

```cangjie
/**
 * 添加资产结果
 * @param assetName 资产名称
 * @param strategyName 策略名称
 * @param result 回测结果
 */
func addAsset(assetName: String, strategyName: String, result: Result): Unit

/**
 * 构建报告
 */
func build(): Unit
```

---

### 5.3 Report 实现类

#### 5.3.1 DataReport

内存数据汇总报告。

**包路径**: `indicator4cj.backtest.DataReport`

**方法**:

```cangjie
/**
 * 获取所有结果
 * @return 结果列表
 */
public func getResults(): ArrayList<Result>
```

---

#### 5.3.2 HtmlReport

可视化 HTML 报告。

**包路径**: `indicator4cj.backtest.HtmlReport`

**构造函数**:

```cangjie
/**
 * 创建 HTML 报告
 * @param path 输出文件路径
 */
public init(path: String)
```

---

### 5.4 ReportFactory 类

报告工厂，用于创建不同类型的报告。

**包路径**: `indicator4cj.backtest.ReportFactory`

**方法**:

```cangjie
/**
 * 创建报告实例
 * @param path 输出路径
 * @return 报告实例
 */
public func createReport(path: String): Report
```

---

## 6. 常量定义

所有常量位于 `indicator4cj.helper.constants` 包中。

### 6.1 RSI 相关常量

| 常量名 | 类型 | 值 | 说明 |
|-------|------|----|----|
| `RSI_SCALE_FACTOR` | `Float64` | 100.0 | RSI 缩放因子 |
| `RSI_DEFAULT_PERIOD` | `Int64` | 14 | RSI 默认周期 |

---

### 6.2 布林带相关常量

| 常量名 | 类型 | 值 | 说明 |
|-------|------|----|----|
| `BOLLINGER_BANDS_MULTIPLIER` | `Float64` | 2.0 | 布林带标准差倍数 |
| `BOLLINGER_BANDS_DEFAULT_PERIOD` | `Int64` | 20 | 布林带默认周期 |
| `BOLLINGER_BANDS_DIVISOR` | `Float64` | 2.0 | 布林带宽度分母 |

---

### 6.3 EMA 相关常量

| 常量名 | 类型 | 值 | 说明 |
|-------|------|----|----|
| `EMA_DEFAULT_SMOOTHING` | `Float64` | 2.0 | EMA 默认平滑系数 |
| `EMA_DEFAULT_PERIOD` | `Int64` | 20 | EMA 默认周期 |

---

### 6.4 MACD 相关常量

| 常量名 | 类型 | 值 | 说明 |
|-------|------|----|----|
| `MACD_DEFAULT_FAST_PERIOD` | `Int64` | 12 | MACD 快速 EMA 默认周期 |
| `MACD_DEFAULT_SLOW_PERIOD` | `Int64` | 26 | MACD 慢速 EMA 默认周期 |
| `MACD_DEFAULT_SIGNAL_PERIOD` | `Int64` | 9 | MACD 信号线 EMA 默认周期 |

---

### 6.5 移动平均常量

| 常量名 | 类型 | 值 | 说明 |
|-------|------|----|----|
| `MA_DEFAULT_PERIOD` | `Int64` | 50 | SMA 默认周期 |
| `MA_SHORT_PERIOD` | `Int64` | 5 | 短期移动平均周期 |
| `MA_MEDIUM_PERIOD` | `Int64` | 20 | 中期移动平均周期 |
| `MA_LONG_PERIOD` | `Int64` | 50 | 长期移动平均周期 |

---

### 6.6 其他常量

| 常量名 | 类型 | 值 | 说明 |
|-------|------|----|----|
| `PERCENTAGE_FACTOR` | `Float64` | 100.0 | 百分比转换因子 |
| `DONCHIAN_CHANNEL_DEFAULT_PERIOD` | `Int64` | 20 | 唐奇安通道默认周期 |
| `ATR_DEFAULT_PERIOD` | `Int64` | 14 | ATR 默认周期 |
| `RMA_DEFAULT_PERIOD` | `Int64` | 20 | RMA 默认周期 |
| `RMA_DEFAULT_SMOOTHING` | `Float64` | 1.0 | RMA 默认平滑因子 |
| `STOCHASTIC_DEFAULT_PERIOD` | `Int64` | 14 | 随机指标默认周期 |
| `STOCHASTIC_DEFAULT_SMOOTH` | `Int64` | 3 | 随机指标默认平滑周期 |
| `SMA_DEFAULT_PERIOD` | `Int64` | 20 | SMA 默认周期 |
| `CHANGE_DEFAULT_PERIOD` | `Int64` | 1 | 默认变动率周期 |

---

## 7. 完整使用示例

### 7.1 基础指标计算

```cangjie
import indicator4cj.helper.*
import indicator4cj.trend.*
import indicator4cj.momentum.*
import indicator4cj.volatility.*

main() {
    // 读取 CSV 数据
    let snapshots = parseCsv("data/AAPL.csv", true)
    let closePrices = map(snapshots, { s => s.close })

    // 计算多个指标
    let sma20 = Sma(20).compute(closePrices)
    let ema20 = Ema(20).compute(closePrices)
    let rsi14 = Rsi(14).compute(closePrices)

    // 计算布林带
    let bb = BollingerBands(20, 2.0)
    let (middle, upper, lower) = bb.compute(closePrices)

    // 打印前 10 个值
    for (i in 0..10) {
        println("SMA20: ${sma20.next()}, EMA20: ${ema20.next()}, RSI14: ${rsi14.next()}")
    }
}
```

---

### 7.2 策略回测

```cangjie
import indicator4cj.helper.*
import indicator4cj.strategy.*
import indicator4cj.backtest.*
import indicator4cj.asset.*

main() {
    // 创建数据仓储
    let repo = FileSystemRepository("data")

    // 创建策略列表
    let strategies = [
        RsiStrategy(),
        MacdStrategy(),
        BollingerBandsStrategy(),
        BuyAndHoldStrategy()
    ]

    // 创建报告工厂
    let reportFactory = ReportFactory()

    // 创建回测引擎
    let backtest = Backtest(repo, strategies, reportFactory)
    backtest.workers = 4
    backtest.lastDays = 365

    // 运行回测
    let error = backtest.run()
    if (let Some(e) <- error) {
        println("回测失败: ${e.message}")
    } else {
        println("回测完成！")
    }
}
```

---

### 7.3 自定义策略组合

```cangjie
import indicator4cj.helper.*
import indicator4cj.strategy.*

main() {
    // 创建基础策略
    let rsi = RsiStrategy()
    let macd = MacdStrategy()
    let bb = BollingerBandsStrategy()

    // 创建组合策略
    let andStrategy = AndStrategy("RSI + MACD + BB", [rsi, macd, bb])

    // 添加止损
    let withStopLoss = StopLossStrategy(andStrategy, 5.0)

    // 反向测试（做空）
    let inverted = InverseStrategy(withStopLoss)

    // 计算动作
    let snapshots = parseCsv("data/AAPL.csv", true)
    let actions = inverted.compute(snapshots)

    // 统计信号
    var buyCount = 0
    var sellCount = 0
    var holdCount = 0

    for (action in actions) {
        match (action) {
            case Buy => buyCount++
            case Sell => sellCount++
            case Hold => holdCount++
        }
    }

    println("买入: ${buyCount}, 卖出: ${sellCount}, 持有: ${holdCount}")
}
```

---

## 8. API 索引

### 8.1 按字母顺序索引

| A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| AccelerationBands | BollingerBands | Cci | Dema | Ema | ForceIndex | | Highest | IchimokuCloud | | Kama | | Ma | NoLossStrategy | Obv | PercentB | Qstick | Rsi | Skip | | | Vwap | WilliamsR | | | |
| Abs | BollingerBandWidth | ChaikinMoneyFlowStrategy | DonchianChannel | Emv | | | | InverseStrategy | | Kdj | | Macd | | | | | | | | Sma | SuperTrend | UlcerIndex | Vpt | Wma | | | |
| Action | BopStrategy | ChaikinOscillator | Duplicate | Envelope | | | | | | KeltnerChannel | | MassIndex | | | | | | | | Smma | | | | | | | | |
| Aroon | BuyAndHoldStrategy | Cmf | | | | | | | | | | Map | | | | | | | | StochasticOscillator | TriX | | | | | | |
| AroonStrategy | | | | | | | | | | | | | | | | | | | | StochasticRsi | Trima | | | | | | |
| ApoStrategy | | | | | | | | | | | | Momentum | | | | | | | | StopLossStrategy | TripleRsiStrategy | | | | | | |
| AndStrategy | | | | | | | | | | | | | | | | | | | &nbsp; | Tsi | | | | | | |
| AwesomeOscillator | | | | | | | | | | | | | | | | | | | | | | | | | | |

---

### 8.2 按类别索引

**核心模型**: Action, Outcome, Result, Snapshot, Repository

**流式计算**: abs, add, apply, change, changePercent, changeRatio, divide, duplicate, filter, highest, lowest, map, multiply, parseCsv, pow, roundDigits, shift, sign, skip, sqrt, subtract

**趋势指标**: Aroon, Apo, Bop, Cci, Dema, Dpo, Ema, Envelope, Hma, Kama, Kdj, Ma, Macd, MassIndex, Mlr, Mls, MovingMax, MovingMin, MovingSum, Rma, Roc, Rsi, Sma, Smma, Tema, Trima, TriX, Tsi, TypicalPrice, Vwma, WeightedClose, Wma

**动量指标**: AwesomeOscillator, ChaikinOscillator, IchimokuCloud, Momentum, Ppo, PringsSpecialK, Pvo, Qstick, Rsi, StochasticOscillator, StochasticRsi, WilliamsR

**波动率指标**: AccelerationBands, Atr, BollingerBands, BollingerBandWidth, ChandelierExit, DonchianChannel, KeltnerChannel, MovingStd, PercentB, Po, SuperTrend, UlcerIndex

**成交量指标**: Ad, Cmf, Emv, ForceIndex, Mfi, Mfm, Mfv, Nvi, Obv, Vpt, Vwap

**策略**: AlligatorStrategy, AndStrategy, ApoStrategy, AroonStrategy, AwesomeOscillatorStrategy, BuyAndHoldStrategy, BollingerBandsStrategy, BopStrategy, CciStrategy, ChaikinMoneyFlowStrategy, DemaStrategy, EaseOfMovementStrategy, EnvelopeStrategy, ForceIndexStrategy, GoldenCrossStrategy, InverseStrategy, KamaStrategy, KdjStrategy, MacdStrategy, MajorityStrategy, MomentumStrategy, NegativeVolumeIndexStrategy, NoLossStrategy, OrStrategy, PercentBAndMfiStrategy, QstickStrategy, RsiStrategy, SmmaStrategy, SplitStrategy, StochasticRsiStrategy, StopLossStrategy, SuperTrendStrategy, TrimaStrategy, TripleMovingAverageCrossoverStrategy, TripleRsiStrategy, TriXStrategy, TsiStrategy, VwmaStrategy, WeightedAveragePriceStrategy, WeightedCloseStrategy

**回测**: Backtest, DataReport, HtmlReport, Report, ReportFactory

---

## 9. 常见问题 (FAQ)

### Q1: 如何处理 Iterator 无法重复消费的问题？

使用 `duplicate` 函数：

```cangjie
let copies = duplicate(source, 3)
let sma20 = Sma(20).compute(copies[0])
let ema20 = Ema(20).compute(copies[1])
```

### Q2: 如何对齐不同指标的输出时间轴？

使用 `shift` 和 `skip` 函数：

```cangjie
let sma20 = Sma(20).compute(closePrices) |> shift(19, 0.0)
let ema20 = Ema(20).compute(closePrices) |> shift(19, 0.0)
```

### Q3: 如何创建自定义策略？

实现 `Strategy` 接口：

```cangjie
class MyStrategy <: Strategy {
    public func name(): String {
        "My Strategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        // 实现策略逻辑
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        // 生成报告
    }
}
```

---

**文档版本**: v1.0.0
**最后更新**: 2025-01-18
**维护者**: indicator4cj 团队
