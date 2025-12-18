package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    private let bands = BollingerBands()

    public init() {}

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        let (upper, middle, lower) = bands.Compute(c)
        return Divide(
            Subtract(upper, lower),
            middle
        )
    }

    public func IdlePeriod(): Int64 { return bands.IdlePeriod() }
}

