package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Vwap {
    private let _sum: MovingSum

    public init() {
        this._sum = MovingSum(14)
    }

    public init(period: Int64) {
        this._sum = MovingSum(period)
    }

    public func Compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        return Divide(
            _sum.Compute(Multiply(closings, vols[0])),
            _sum.Compute(vols[1])
        )
    }

    public func IdlePeriod(): Int64 { return _sum.IdlePeriod() }
}

