package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*

// Momentum = Current - value N steps before.
public class Momentum {
    public var period: Int64 = 10

    public Momentum() { this.period = period }
    public init(period: Int64) { this.period = period }

    // compute 计算动量指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return Change(values, this.period)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period }
}

