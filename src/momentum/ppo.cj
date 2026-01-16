package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// PPO = 100 * (EMA_fast - EMA_slow) / EMA_slow
public class Ppo {
    // 快速周期
    public var FastPeriod: Int64 = 12
    // 慢速周期
    public var SlowPeriod: Int64 = 26

    public Ppo() {
        this.FastPeriod = FastPeriod
        this.SlowPeriod = SlowPeriod
    }

    public init(fast: Int64, slow: Int64) {
        this.FastPeriod = fast
        this.SlowPeriod = slow
    }

    // compute 计算价格振荡器指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let fastEma = Ema(this.FastPeriod).compute(values)
        let slowEma = Ema(this.SlowPeriod).compute(values)
        let diff = Subtract(fastEma, slowEma)
        return MultiplyBy(Divide(diff, slowEma), 100.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.SlowPeriod - 1 }
}

