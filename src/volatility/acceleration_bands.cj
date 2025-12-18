package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class AccelerationBands {
    public var Period: Int64

    public init() { this.Period = 20 }
    public init(period: Int64) { this.Period = period }

    public func Compute(high: Iterator<Float64>, low: Iterator<Float64>, closing: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let highs = Duplicate(high, 3)
        let lows = Duplicate(low, 3)

        let ks = Duplicate(
            Divide(
                Subtract(highs[0], lows[0]),
                Add(highs[1], lows[1])
            ),
            2
        )

        let sma = Sma()
        sma.Period = Period

        let upper = sma.Compute(
            Multiply(
                highs[2],
                IncrementBy(
                    MultiplyBy(ks[0], 4.0),
                    1.0
                )
            )
        )

        let middle = sma.Compute(closing)

        let lower = sma.Compute(
            Multiply(
                lows[2],
                IncrementBy(
                    MultiplyBy(ks[1], -4.0),
                    1.0
                )
            )
        )

        return (upper, middle, lower)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

