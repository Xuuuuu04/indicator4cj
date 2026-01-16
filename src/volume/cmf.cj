package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Chaikin 资金流量。
public class Cmf {
    private let _mfv = Mfv()
    private let _sum = MovingSum()

    public Cmf() {
        _sum.period = 20
    }

    public init(period: Int64) {
        _sum.period = period
    }

    // compute 计算蔡金资金流量指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        let mfvs = _mfv.compute(highs, lows, closings, vols[0])
        return Divide(
            _sum.compute(mfvs),
            _sum.compute(vols[1])
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _sum.idlePeriod() }
}

