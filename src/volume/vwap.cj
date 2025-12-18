package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Vwap {
    private let Sum: MovingSum

    public init() {
        this.Sum = MovingSum(14)
    }

    public init(period: Int64) {
        this.Sum = MovingSum(period)
    }

    public func Compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        return Divide(
            Sum.Compute(Multiply(closings, vols[0])),
            Sum.Compute(vols[1])
        )
    }

    public func IdlePeriod(): Int64 { return Sum.IdlePeriod() }
}

