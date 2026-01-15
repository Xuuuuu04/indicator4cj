package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class PercentB {
    private let bands = BollingerBands()

    public init() {}
    public init(period: Int64) { bands.period = period }

    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let closes = Duplicate(closings, 2)
        let (upper, middle, lower) = bands.compute(closes[0])
        closes[1] = Skip(closes[1], bands.idlePeriod())
        // middle is drained
        Drain(middle)
        return Operate3(upper, lower, closes[1], { ub: Float64, lb: Float64, c: Float64 =>
            return (c - lb) / (ub - lb)
        })
    }

    public func idlePeriod(): Int64 { return bands.idlePeriod() }

    public func toString(): String { return "%B(${bands.period})" }
}

