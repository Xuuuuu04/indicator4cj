package indicator4cj.trend

import std.core.*
import std.math.*
import indicator4cj.helper.*

// Hull Moving Average (HMA) for Float64.
public class Hma {
    private let _wma1: Wma
    private let _wma2: Wma
    private let _wma3: Wma

    public init(period: Int64) {
        // Empirically, to match Go's test data (hma.csv), we must use ROUNDING,
        // even though Go source code suggests truncation.
        // This implies the CSV might be generated with a different version or logic.
        let p1 = Int64(round(Float64(period) / 2.0))
        let p3 = Int64(round(sqrt(Float64(period))))

        this._wma1 = Wma(p1)
        this._wma2 = Wma(period)
        this._wma3 = Wma(p3)
    }

    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let vals = Duplicate(values, 2)

        let w1 = _wma1.compute(vals[0])
        let w2 = _wma2.compute(vals[1])

        let combined = Subtract(
            MultiplyBy(w1, 2.0),
            w2
        )

        return _wma3.compute(combined)
    }

    public func idlePeriod(): Int64 {
        return _wma1.idlePeriod() + _wma3.idlePeriod()
    }

    public func toString(): String { return "HMA(${_wma2.period})" }
}

// Hma conforms to Ma.
extend Hma <: Ma {}
