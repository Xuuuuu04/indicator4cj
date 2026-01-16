package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// PPO = 100 * (EMA_fast - EMA_slow) / EMA_slow
public class Ppo {
    // 快速周期
    public var fastPeriod: Int64 = 12
    // 慢速周期
    public var slowPeriod: Int64 = 26

    public Ppo() {
        this.fastPeriod = fastPeriod
        this.slowPeriod = slowPeriod
    }

    public init(fast: Int64, slow: Int64) {
        this.fastPeriod = fast
        this.slowPeriod = slow
    }

    // compute 计算价格振荡器指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let fastEma = Ema(fastPeriod).compute(values)
        let slowEma = Ema(slowPeriod).compute(values)
        let diff = Subtract(fastEma, slowEma)
        return MultiplyBy(Divide(diff, slowEma), 100.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return slowPeriod - 1 }
}

