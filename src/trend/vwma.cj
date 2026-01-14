package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultVwmaPeriod: Int64 = 20

// Volume Weighted Moving Average (VWMA)
public class Vwma {
    public var Period: Int64

    public init() { this.Period = DefaultVwmaPeriod }
    public init(period: Int64) { this.Period = period }

    public func compute(closing: Iterator<Float64>, volume: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volume, 2)
        let sum = MovingSum()
        sum.Period = Period
        return Divide(
            sum.compute(Multiply(closing, vols[0])),
            sum.compute(vols[1])
        )
    }

    public func idlePeriod(): Int64 { return Period - 1 }
}

