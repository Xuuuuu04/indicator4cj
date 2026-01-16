package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// PVO = 100 * (EMA_fast(volume) - EMA_slow(volume)) / EMA_slow(volume)
public class Pvo {
    // 快速周期
    public var fastPeriod: Int64 = 12
    // 慢速周期
    public var slowPeriod: Int64 = 26

    public Pvo() {
        this.fastPeriod = fastPeriod
        this.slowPeriod = slowPeriod
    }

    public init(fast: Int64, slow: Int64) {
        this.fastPeriod = fast
        this.slowPeriod = slow
    }

    // compute 计算成交量振荡器指标。
    public func compute(volumes: Iterator<Float64>): Iterator<Float64> {
        let fastEma = Ema(this.fastPeriod).compute(volumes)
        let slowEma = Ema(this.slowPeriod).compute(volumes)
        let diff = Subtract(fastEma, slowEma)
        return MultiplyBy(Divide(diff, slowEma), 100.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.slowPeriod - 1 }
}

