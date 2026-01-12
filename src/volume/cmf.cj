package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Chaikin Money Flow.
public class Cmf {
    private let _mfv = Mfv()
    private let _sum = MovingSum()

    public init() { _sum.Period = 20 }
    public init(period: Int64) { _sum.Period = period }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        let mfvs = _mfv.Compute(highs, lows, closings, vols[0])
        return Divide(
            _sum.Compute(mfvs),
            _sum.Compute(vols[1])
        )
    }

    public func IdlePeriod(): Int64 { return _sum.IdlePeriod() }
}

