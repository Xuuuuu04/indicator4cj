package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultVwmaPeriod: Int64 = 20

// Volume Weighted Moving Average (VWMA)
public class Vwma {
    // 周期
    public var period: Int64 = DefaultVwmaPeriod

    public Vwma() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    public func compute(closing: Iterator<Float64>, volume: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volume, 2)
        let sum = MovingSum()
        sum.period = this.period
        return Divide(
            sum.compute(Multiply(closing, vols[0])),
            sum.compute(vols[1])
        )
    }

    public func idlePeriod(): Int64 { return this.period - 1 }
}
