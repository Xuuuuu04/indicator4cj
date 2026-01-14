package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTrixPeriod: Int64 = 15

// Triple Exponential Average (TRIX): EMA3 diff ratio.
public class Trix {
    public var Period: Int64

    public init() { this.Period = DefaultTrixPeriod }
    public init(period: Int64) { this.Period = period }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Ema(Period)
        let ema2 = Ema(Period)
        let ema3 = Ema(Period)

        let emas = ema3.compute(ema2.compute(ema1.compute(c)))
        let trix = ChangeRatio(emas, 1)
        return trix
    }

    public func idlePeriod(): Int64 {
        return (Period * 3) - 3 + 1
    }
}

