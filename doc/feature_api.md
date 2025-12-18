# indicator4cj API 参考手册 (Full API Coverage)

本文档罗列了 `indicator4cj` 库中所有对外的公开类、接口、函数及常量。

---

## 1. 核心模型与数据 (Asset & Data Models)

### `class Snapshot`
标准行情快照。
- `Date: DateTime`
- `Open: Float64`
- `High: Float64`
- `Low: Float64`
- `Close: Float64`
- `AdjClose: Float64`
- `Volume: Float64`

### `interface Repository`
资产数据仓储接口。
- `func Assets(): (ArrayList<String>, Option<Exception>)`
- `func Get(name: String): (Iterator<Snapshot>, Option<Exception>)`
- `func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>)`
- `func LastDate(name: String): (Option<DateTime>, Option<Exception>)`
- `func Append(name: String, snapshots: Iterator<Snapshot>): Option<Exception>`

### `class FileSystemRepository`
- `func NewFileSystemRepository(root: String): FileSystemRepository`

### `class TiingoRepository`
- `func NewTiingoRepository(apiKey: String): TiingoRepository`

---

## 2. 流式计算辅助 (Helper Utilities)

### 基础算子
- `func Duplicate<T>(iter: Iterator<T>, n: Int64): ArrayList<Iterator<T>>`: 一分多流转换。
- `func Map<F, T>(iter: Iterator<F>, mapper: (F) -> T): Iterator<T>`: 链式转换。
- `func Apply<T>(iter: Iterator<T>, mapper: (T) -> T): Iterator<T>`: 原地应用。
- `func Shift<T>(iter: Iterator<T>, count: Int64, fill: T): Iterator<T>`: 时间序列位移。
- `func Skip<T>(iter: Iterator<T>, count: Int64): Iterator<T>`: 跳过前 N 项。
- `func Pipe<T>(source: Iterator<T>, sink: (T) -> Unit)`: 消费流。

### 数学与统计
- `func Abs(iter: Iterator<Float64>): Iterator<Float64>`
- `func Add(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>`
- `func Subtract(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>`
- `func Multiply(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>`
- `func Divide(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64>`
- `func RoundDigits(iter: Iterator<Float64>, d: Int64): Iterator<Float64>`
- `func Sign(iter: Iterator<Float64>): Iterator<Float64>`
- `func Pow(iter: Iterator<Float64>, exp: Float64): Iterator<Float64>`
- `func Sqrt(iter: Iterator<Float64>): Iterator<Float64>`

---

## 3. 技术指标 (Technical Indicators)

### 趋势指标 (Trend)
- `class Sma(period: Int64)`: 简单移动平均线。
- `class Ema(period: Int64)`: 指数移动平均线。
- `class Wma(period: Int64)`: 加权移动平均线。
- `class Hma(period: Int64)`: 赫尔移动平均线。
- `class Macd(p1, p2, p3)`: 指数平滑异同移动平均线。
- `class Aroon(period: Int64)`: 阿隆指标。
- `class Bop()`: 力量均衡指标。
- `class Cci(period: Int64)`: 顺势指标。
- `class Dema(period: Int64)`: 双指数移动平均线。
- `class Kama(er, fast, slow)`: 考夫曼自适应移动平均线。
- `class Tsi(p1, p2)`: 真实强度指数。
- `class SuperTrend(period, multiplier)`: 超级趋势指标。

### 动量指标 (Momentum)
- `class Rsi(period: Int64)`: 相对强弱指数。
- `class StochasticOscillator(period: Int64)`: 随机振荡指标 (%K, %D)。
- `class StochasticRsi(period: Int64)`: 随机相对强弱指数。
- `class AwesomeOscillator()`: 动量震荡指标。
- `class WilliamsR(period: Int64)`: 威廉指标。
- `class Momentum(period: Int64)`: 动量。

### 波动率指标 (Volatility)
- `class Atr(ma: Ma)`: 平均真实波幅。
- `class BollingerBands(period: Int64)`: 布林带。
- `class KeltnerChannel(period: Int64)`: 肯特纳通道。
- `class DonchianChannel(period: Int64)`: 唐奇安通道。

### 成交量指标 (Volume)
- `class Obv()`: 能量潮指标。
- `class Mfi(period: Int64)`: 资金流量指标。
- `class Nvi(initial: Float64)`: 负成交量指数。
- `class Vwap()`: 成交量加权平均价。

---

## 4. 交易策略 (Trading Strategy)

### 核心接口
- `interface Strategy`: 定义策略行为。
- `enum Action`: `Buy`, `Hold`, `Sell`。

### 策略构建器
- `func NewRsiStrategy(): Strategy`
- `func NewMacdStrategy(): Strategy`
- `func NewBollingerBandsStrategy(): Strategy`
- `func NewSuperTrendStrategy(): Strategy`
- `func NewBuyAndHoldStrategy(): Strategy`

### 策略装饰器
- `class StopLossStrategy(base, percentage)`: 止损。
- `class NoLossStrategy(base)`: 无损保护。
- `class InverseStrategy(base)`: 信号反转。

### 逻辑组合
- `class AndStrategy(name)`
- `class OrStrategy(name)`
- `class MajorityStrategy(name)`

---

## 5. 回测框架 (Backtesting)

### 执行与调度
- `class Backtest(repo, strategies, reportFactory)`:
  - `var Workers: Int64`: 并发资产数。
  - `var LastDays: Int64`: 追溯天数。
  - `func Run(): Option<Exception>`

### 报告生成
- `interface Report`: 报表接口。
- `class DataReport`: 内存数据汇总。
- `class HtmlReport`: 导出 HTML 网页。
- `func RegisterReportBuilder(name, builder)`: 注册自定义报表。
