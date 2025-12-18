package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*

// Momentum = Current - value N steps before.
public class Momentum {
    public var Period: Int64

    public init() { this.Period = 10 }
    public init(period: Int64) { this.Period = period }

    public func Compute(values: Iterator<Float64>): Iterator<Float64> {
        return Change(values, Period)
    }

    public func IdlePeriod(): Int64 { return Period }
}

