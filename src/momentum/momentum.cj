package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*

// Momentum = Current - value N steps before.
public class Momentum {
    public var period: Int64 = 10

    public Momentum() { this.period = period }
    public init(period: Int64) { this.period = period }

    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return Change(values, this.period)
    }

    public func idlePeriod(): Int64 { return this.period }
}

