package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    private let bands = BollingerBands()

    public BollingerBandWidth() {}

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let (upper, middle, lower) = bands.compute(c)
        return Divide(
            Subtract(upper, lower),
            middle
        )
    }

    public func idlePeriod(): Int64 { return bands.idlePeriod() }
}

