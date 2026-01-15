package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Vwap {
    private let sum: MovingSum

    public init() {
        this.sum = MovingSum(14)
    }

    public init(period: Int64) {
        this.sum = MovingSum(period)
    }

    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let vols = Duplicate(volumes, 2)
        return Divide(
            sum.compute(Multiply(closings, vols[0])),
            sum.compute(vols[1])
        )
    }

    public func idlePeriod(): Int64 { return sum.idlePeriod() }
}

