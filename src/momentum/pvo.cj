package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// PVO = 100 * (EMA_fast(volume) - EMA_slow(volume)) / EMA_slow(volume)
public class Pvo {
    public var FastPeriod: Int64
    public var SlowPeriod: Int64

    public init() {
        this.FastPeriod = 12
        this.SlowPeriod = 26
    }

    public init(fast: Int64, slow: Int64) {
        this.FastPeriod = fast
        this.SlowPeriod = slow
    }

    public func Compute(volumes: Iterator<Float64>): Iterator<Float64> {
        let fastEma = Ema(FastPeriod).Compute(volumes)
        let slowEma = Ema(SlowPeriod).Compute(volumes)
        let diff = Subtract(fastEma, slowEma)
        return MultiplyBy(Divide(diff, slowEma), 100.0)
    }

    public func IdlePeriod(): Int64 { return SlowPeriod - 1 }
}

