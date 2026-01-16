package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Chaikin Money Flow.
public class Cmf {
    private let mfv = Mfv()
    private let sum = MovingSum()

    public Cmf() {
        sum.period = 20
    }

    public init(period: Int64) {
        sum.period = period
    }

    // compute 计算蔡金资金流量指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        let mfvs = mfv.compute(highs, lows, closings, vols[0])
        return Divide(
            sum.compute(mfvs),
            sum.compute(vols[1])
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return sum.idlePeriod() }
}

