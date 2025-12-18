package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Simple Moving Average (Float64).
public class Sma {
    public var Period: Int64

    public init() { this.Period = 50 }
    public init(period: Int64) { this.Period = period }

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        let sum = MovingSum()
        sum.Period = Period
        return DivideBy(sum.Compute(c), Float64(Period))
    }

    public func IdlePeriod(): Int64 { return Period - 1 }

    public func toString(): String { return "SMA(${Period})" }
}

