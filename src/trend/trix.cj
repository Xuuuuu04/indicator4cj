package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTrixPeriod: Int64 = 15

// Triple Exponential Average (TRIX): EMA3 diff ratio.
public class Trix {
    // 周期
    public var period: Int64 = DefaultTrixPeriod

    public Trix() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

// compute 计算指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Ema(this.period)
        let ema2 = Ema(this.period)
        let ema3 = Ema(this.period)

        let emas = ema3.compute(ema2.compute(ema1.compute(c)))
        let trix = ChangeRatio(emas, 1)
        return trix
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return (this.period * 3) - 3 + 1
    }
}
