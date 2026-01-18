# Package strategy

`strategy` 包实现了交易逻辑层，支持从简单的指标交叉到复杂的装饰器增强策略。

## 策略类型

### 1. 基础策略 (Base Strategies)

基于单一技术指标的策略实现。

#### 趋势策略 (Trend Strategies)

- **GoldenCrossStrategy**：金叉策略（短期均线上穿长期均线）
- **DeathCrossStrategy**：死叉策略（短期均线下穿长期均线）
- **MacdStrategy**：MACD 指标策略
- **ApoStrategy**：绝对价格振荡指标策略
- **AroonStrategy**：阿隆指标策略
- **BopStrategy**：力量均衡指标策略
- **CciStrategy**：商品通道指标策略
- **DemaStrategy**：双指数移动平均策略
- **EnvelopeStrategy**：包络线策略
- **KamaStrategy**：考夫曼自适应移动平均策略
- **KdjStrategy**：随机指标策略
- **QstickStrategy**：Qstick 指标策略
- **SmmaStrategy**：平滑移动平均策略
- **TrimaStrategy**：三角移动平均策略
- **TrixStrategy**：三重指数平滑移动平均策略
- **TsiStrategy**：真实强度指数策略
- **VwmaStrategy**：成交量加权移动平均策略
- **WeightedCloseStrategy**：加权收盘价策略
- **TripleMovingAverageCrossoverStrategy**：三均线交叉策略
- **AlligatorStrategy**：鳄鱼指标策略

#### 动量策略 (Momentum Strategies)

- **RsiStrategy**：相对强弱指数策略
- **TripleRsiStrategy**：三重 RSI 策略
- **StochasticRsiStrategy**：随机 RSI 策略
- **AwesomeOscillatorStrategy**：动量震荡指标策略

#### 成交量策略 (Volume Strategies)

- **BollingerBandsStrategy**：布林带策略
- **SuperTrendStrategy**：超级趋势指标策略
- **ChaikinMoneyFlowStrategy**：蔡金资金流量策略
- **EaseOfMovementStrategy**：简易波动指标策略
- **ForceIndexStrategy**：强力指数策略
- **MoneyFlowIndexStrategy**：资金流量指数策略
- **NegativeVolumeIndexStrategy**：负成交量指数策略
- **PercentBAndMfiStrategy**：%B 和 MFI 组合策略
- **WeightedAveragePriceStrategy**：成交量加权平均价策略

### 2. 逻辑组合策略 (Logic Compounds)

通过逻辑运算组合多个子策略。

#### AndStrategy

所有子策略同时发出信号时才执行交易。

```cangjie
public class AndStrategy <: Strategy {
    public init(name: String, strategies: ArrayList<Strategy>)

    // 只有当所有子策略都返回 BUY 时，才返回 BUY
    // 只有当所有子策略都返回 SELL 时，才返回 SELL
    // 否则返回 HOLD
}
```

**使用示例**：

```cangjie
let strategies = ArrayList<Strategy>()
strategies.add(RsiStrategy())
strategies.add(MacdStrategy())

let combined = AndStrategy("RSI+MACD", strategies)
// 只有 RSI 和 MACD 同时买入时才买入
```

#### OrStrategy

任意子策略发出信号时就执行交易。

```cangjie
public class OrStrategy <: Strategy {
    public init(name: String, strategies: ArrayList<Strategy>)

    // 任意子策略返回 BUY，则返回 BUY
    // 任意子策略返回 SELL，则返回 SELL
    // 否则返回 HOLD
}
```

**使用示例**：

```cangjie
let strategies = ArrayList<Strategy>()
strategies.add(RsiStrategy())
strategies.add(StochasticStrategy())

let combined = OrStrategy("RSI_or_Stoch", strategies)
// RSI 或 Stochastic 任意一个买入就买入
```

#### MajorityStrategy

少数服从多数的投票机制。

```cangjie
public class MajorityStrategy <: Strategy {
    public init(name: String, strategies: ArrayList<Strategy>)

    // 大多数子策略返回 BUY，则返回 BUY
    // 大多数子策略返回 SELL，则返回 SELL
    // 否则返回 HOLD
}
```

**使用示例**：

```cangjie
let strategies = ArrayList<Strategy>()
strategies.add(RsiStrategy())
strategies.add(MacdStrategy())
strategies.add(BollingerBandsStrategy())

let voting = MajorityStrategy("Majority", strategies)
// 3个策略中至少2个同意才执行
```

#### SplitStrategy

将买入逻辑和卖出逻辑分离，由不同策略控制。

```cangjie
public class SplitStrategy <: Strategy {
    public init(buyStrategy: Strategy, sellStrategy: Strategy)

    // 买入信号来自 buyStrategy
    // 卖出信号来自 sellStrategy
}
```

**使用示例**：

```cangjie
let buy = RsiStrategy()        // RSI 超卖买入
let sell = MacdStrategy()      // MACD 死叉卖出
let split = SplitStrategy(buy, sell)
```

### 3. 策略装饰器 (Decorators)

在不修改原策略的情况下增强功能。

#### StopLossStrategy (止损策略)

自动计算止损点，触发后强制平仓。

```cangjie
public class StopLossStrategy <: Strategy {
    public init(base: Strategy, percentage: Float64)

    // percentage: 止损百分比（如 0.05 表示 5%）
    // 当亏损超过 percentage 时自动卖出
}
```

**使用示例**：

```cangjie
let base = RsiStrategy()
let withStopLoss = StopLossStrategy(base, 0.05)
// 亏损 5% 时自动止损
```

#### NoLossStrategy (无损保护策略)

保护本金，确保不会亏损。

```cangjie
public class NoLossStrategy <: Strategy {
    public init(base: Strategy)

    // 当即将亏损时，强制卖出保持盈亏平衡
}
```

**使用示例**：

```cangjie
let base = BuyAndHoldStrategy()
let protected = NoLossStrategy(base)
// 保证不会出现亏损
```

#### InverseStrategy (反向策略)

反转所有买卖信号。

```cangjie
public class InverseStrategy <: Strategy {
    public init(base: Strategy)

    // 原策略 BUY → 反向策略 SELL
    // 原策略 SELL → 反向策略 BUY
    // 原策略 HOLD → 反向策略 HOLD
}
```

**使用示例**：

```cangjie
let base = RsiStrategy()
let inverse = InverseStrategy(base)
// RSI 说买入时卖出，RSI 说卖出时买入
```

### 4. 复合策略 (Compound Strategies)

组合多个指标形成复杂策略。

#### MacdRsiStrategy

MACD 和 RSI 的组合策略。

```cangjie
public class MacdRsiStrategy <: Strategy {
    // MACD 趋势 + RSI 动量
    // 在趋势向上的情况下，RSI 超卖时买入
}
```

## 核心接口

### Strategy 接口

所有策略必须实现此接口。

```cangjie
public interface Strategy {
    func name(): String                                     // 策略名称
    func compute(snapshots: Iterator<Snapshot>): Iterator<Action> // 生成买卖信号
    func report(snapshots: Iterator<Snapshot>): Report      // 生成策略报告
}
```

### Action 枚举

交易动作类型。

```cangjie
public enum Action <: ToString & Equatable<Action> {
    | BUY    // 买入信号
    | SELL   // 卖出信号
    | HOLD   // 持有/观望
}
```

### Result 类

策略执行结果。

```cangjie
public class Result {
    public var asset: String                // 资产名称
    public var strategy: String             // 策略名称
    public var actions: ArrayList<Action>   // 动作序列
    public var outcomes: ArrayList<Float64> // 收益率序列
}
```

## 使用示例

### 基础策略使用

```cangjie
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum.*
import indicator4cj.asset.*

main() {
    let repo = InMemoryRepository()
    let snaps = loadFromCsv<Snapshot>("AAPL.csv")
    repo.append("AAPL", snaps)

    // 创建 RSI 策略
    let strategy = RsiStrategy()

    // 计算交易信号
    match (repo.get("AAPL")) {
        case Some(data) => {
            let actions = strategy.compute(data)
            // 处理交易信号...
        }
        case None => ()
    }
}
```

### 装饰器链

```cangjie
// 创建装饰器链
let base = RsiStrategy()
let withStopLoss = StopLossStrategy(base, 0.05)
let protected = NoLossStrategy(withStopLoss)
let final = InverseStrategy(protected)

// 最终策略功能：
// 1. 基于 RSI 信号
// 2. 自动止损 5%
// 3. 保护本金不亏损
// 4. 反向所有信号
```

### 逻辑组合

```cangjie
// 创建策略组合
let strategies = ArrayList<Strategy>()
strategies.add(RsiStrategy())
strategies.add(MacdStrategy())
strategies.add(BollingerBandsStrategy())

// 少数服从多数
let voting = MajorityStrategy("VotingStrategy", strategies)

// 2:1 多数通过才执行交易
```

## 策略开发指南

### 创建自定义策略

```cangjie
import indicator4cj.strategy.*
import indicator4cj.asset.*

public class MyCustomStrategy <: Strategy {
    public func name(): String {
        return "MyCustomStrategy"
    }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        // 1. 计算技术指标
        let closings = snapshotsAsClosings(snapshots)
        let rsi = Rsi(14)
        let rsiValues = rsi.compute(closings)

        // 2. 生成交易信号
        return generateSignals(rsiValues)
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        let actions = compute(snapshots)
        let outcomes = outcome(snapshotsAsClosings(snapshots), actions)
        return generateReport("MyCustomStrategy", snapshots, actions, outcomes)
    }
}
```

### 最佳实践

1. **单一职责**：每个策略只负责一种交易逻辑
2. **可组合性**：设计时考虑与其他策略组合的可能性
3. **参数化**：将关键参数提取为可配置项
4. **文档完整**：详细说明策略原理和适用场景
5. **充分测试**：使用历史数据进行充分回测

## 注意事项

1. **历史表现不代表未来**：回测表现好的策略不一定在实盘中有效
2. **避免过度拟合**：不要过度优化参数以适应历史数据
3. **考虑交易成本**：实盘交易需要考虑佣金、滑点等成本
4. **风险管理**：始终设置止损，控制单笔交易风险
5. **持续监控**：定期评估策略表现，必要时调整或停止使用
