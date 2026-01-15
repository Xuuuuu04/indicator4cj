package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultCciPeriod: Int64 = 20

// Commodity Channel Index (CCI)
public class Cci {
    public var period: Int64

    public init() { this.period = DefaultCciPeriod }
    public init(period: Int64) { this.period = period }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let tp = TypicalPrice()
        let sma1 = Sma(this.period)
        let sma2 = Sma(this.period)

        let tps = Duplicate(tp.compute(highs, lows, closings), 3)

        let mas = Duplicate(sma1.compute(tps[0]), 2)

        tps[1] = Skip(tps[1], sma1.period - 1)
        tps[2] = Skip(tps[2], sma1.period - 1)

        let md = sma2.compute(
            Abs(
                Subtract(tps[1], mas[0])
            )
        )

        mas[1] = Skip(mas[1], sma2.period - 1)
        tps[2] = Skip(tps[2], sma2.period - 1)

        let cci = Divide(
            Subtract(tps[2], mas[1]),
            MultiplyBy(md, 0.015)
        )

        return cci
    }

    public func idlePeriod(): Int64 {
        return (this.period * 2) - 2
    }
}

