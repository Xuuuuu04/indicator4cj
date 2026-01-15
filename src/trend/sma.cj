package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Simple Moving Average (Float64).
public class Sma {
    public var period: Int64 = 50

    public Sma() { this.period = period }
    public init(period: Int64) { this.period = period }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let sum = MovingSum()
        sum.period = this.period
        return DivideBy(sum.compute(c), Float64(this.period))
    }

    public func idlePeriod(): Int64 { return this.period - 1 }

    public func toString(): String { return "SMA(${this.period})" }
}

