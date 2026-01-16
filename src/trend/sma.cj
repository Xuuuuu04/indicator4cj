package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Simple Moving Average (Float64).
public class Sma {
    // 周期
    public var period: Int64 = 50

    public Sma() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算简单移动平均线。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let sum = MovingSum()
        sum.period = period
        return DivideBy(sum.compute(c), Float64(period))
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }

    // toString 返回指标的字符串表示。
    public func toString(): String { return "SMA(${period})" }
}

