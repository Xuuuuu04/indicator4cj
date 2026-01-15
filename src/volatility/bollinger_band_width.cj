package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    private let _bands = BollingerBands()

    public BollingerBandWidth() {}

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let (upper, middle, lower) = _bands.compute(c)
        return Divide(
            Subtract(upper, lower),
            middle
        )
    }

    public func idlePeriod(): Int64 { return _bands.idlePeriod() }
}

