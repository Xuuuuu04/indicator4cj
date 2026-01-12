package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    private let _bands = BollingerBands()

    public init() {}

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        let (upper, middle, lower) = _bands.Compute(c)
        return Divide(
            Subtract(upper, lower),
            middle
        )
    }

    public func IdlePeriod(): Int64 { return _bands.IdlePeriod() }
}

