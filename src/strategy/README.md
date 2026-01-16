# Package strategy

`strategy` 包实现了交易逻辑层，支持从简单的指标交叉到复杂的装饰器增强策略。

## 策略类型

1. **基础策略 (Base Strategies):**
   - 趋势策略：MACD, Alligator, Aroon 等。
   - 动量策略：RSI, Stochastic RSI 等。
   - 成交量策略：MFI, NVI, VWAP 等。

2. **逻辑组合策略 (Logic Compounds):**
   - `AndStrategy`: 多个子策略同时发出信号时买入/卖出。
   - `OrStrategy`: 任意子策略发出信号时即行动。
   - `MajorityStrategy`: 少数服从多数的投票机制。

3. **策略装饰器 (Decorators):**
   - `StopLossStrategy`: 自动计算风险并在触发止损点时强制平仓。
   - `NoLossStrategy`: 保护性装饰器，防止本金受损。
   - `InverseStrategy`: 反转所有买卖信号。

4. **分片策略 (Split Strategy):**
   - 允许将买入逻辑与卖出逻辑由两个完全不同的策略独立控制。
