package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*

// 动量指标 = 当前值 - N个周期前的值。
public class Momentum {
    // 周期
    public var period: Int64 = 10

    public Momentum() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算动量指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return change(values, period)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period }
}

