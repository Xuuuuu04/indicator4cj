package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTrixPeriod: Int64 = 15

// Triple Exponential Average (TRIX): EMA3 diff ratio.
public class Trix {
    public var Period: Int64

    public init() { this.Period = DefaultTrixPeriod }
    public init(period: Int64) { this.Period = period }

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Ema(Period)
        let ema2 = Ema(Period)
        let ema3 = Ema(Period)

        let emas = ema3.Compute(ema2.Compute(ema1.Compute(c)))
        let trix = ChangeRatio(emas, 1)
        return trix
    }

    public func IdlePeriod(): Int64 {
        return (Period * 3) - 3 + 1
    }
}

public func NewTrix(): Trix { return Trix() }


