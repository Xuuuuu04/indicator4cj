package indicator4cj.trend

import std.core.*
import std.math.*
import indicator4cj.helper.*

// Hull Moving Average (HMA) for Float64.
public class Hma {
    private let wma1: Wma
    private let wma2: Wma
    private let wma3: Wma

    public init(period: Int64) {
        // Empirically, to match Go's test data (hma.csv), we must use ROUNDING,
        // even though Go source code suggests truncation. 
        // This implies the CSV might be generated with a different version or logic.
        let p1 = Int64(round(Float64(period) / 2.0))
        let p3 = Int64(round(sqrt(Float64(period))))
        
        this.wma1 = Wma(p1)
        this.wma2 = Wma(period)
        this.wma3 = Wma(p3)
    }

    public func Compute(values: Iterator<Float64>): Iterator<Float64> {
        let vals = Duplicate(values, 2)

        let w1 = wma1.Compute(vals[0])
        let w2 = wma2.Compute(vals[1])

        let combined = Subtract(
            MultiplyBy(w1, 2.0),
            w2
        )

        return wma3.Compute(combined)
    }

    public func IdlePeriod(): Int64 {
        return wma1.IdlePeriod() + wma3.IdlePeriod()
    }

    public func toString(): String { return "HMA(${wma2.Period})" }
}

// Hma conforms to Ma.
extend Hma <: Ma {}
