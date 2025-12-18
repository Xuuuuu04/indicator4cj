package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Chaikin Money Flow.
public class Cmf {
    private let mfv = Mfv()
    private let sum = MovingSum()

    public init() { sum.Period = 20 }
    public init(period: Int64) { sum.Period = period }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        let mfvs = mfv.Compute(highs, lows, closings, vols[0])
        return Divide(
            sum.Compute(mfvs),
            sum.Compute(vols[1])
        )
    }

    public func IdlePeriod(): Int64 { return sum.IdlePeriod() }
}

