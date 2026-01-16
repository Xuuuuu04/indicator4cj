package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// PVO = 100 * (EMA_fast(volume) - EMA_slow(volume)) / EMA_slow(volume)
public class Pvo {
    // 快速周期
    public var FastPeriod: Int64 = 12
    // 慢速周期
    public var SlowPeriod: Int64 = 26

    public Pvo() {
        this.FastPeriod = FastPeriod
        this.SlowPeriod = SlowPeriod
    }

    public init(fast: Int64, slow: Int64) {
        this.FastPeriod = fast
        this.SlowPeriod = slow
    }

    // compute 计算成交量振荡器指标。
    public func compute(volumes: Iterator<Float64>): Iterator<Float64> {
        let fastEma = Ema(this.FastPeriod).compute(volumes)
        let slowEma = Ema(this.SlowPeriod).compute(volumes)
        let diff = Subtract(fastEma, slowEma)
        return MultiplyBy(Divide(diff, slowEma), 100.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.SlowPeriod - 1 }
}

