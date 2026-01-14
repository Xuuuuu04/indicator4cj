package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class PercentB {
    private let _bands = BollingerBands()

    public init() {}
    public init(period: Int64) { _bands.Period = period }

    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let closes = Duplicate(closings, 2)
        let (upper, middle, lower) = _bands.compute(closes[0])
        closes[1] = Skip(closes[1], _bands.idlePeriod())
        // middle is drained
        Drain(middle)
        return Operate3(upper, lower, closes[1], { ub: Float64, lb: Float64, c: Float64 =>
            return (c - lb) / (ub - lb)
        })
    }

    public func idlePeriod(): Int64 { return _bands.idlePeriod() }

    public func toString(): String { return "%B(${_bands.Period})" }
}

