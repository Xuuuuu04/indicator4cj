package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultDpoPeriod: Int64 = 20

// Detrended Price Oscillator (DPO)
public class Dpo {
    public var Period: Int64

    public init() { this.Period = DefaultDpoPeriod }
    public init(period: Int64) {
        if (period <= 1) {
            this.Period = DefaultDpoPeriod
        } else {
            this.Period = period
        }
    }

    public func Compute(closing: Iterator<Float64>): Iterator<Float64> {
        let k = Period / 2 + 1
        let dup = Duplicate(closing, 2)

        let sma = Sma()
        sma.Period = Period
        let smaOut = sma.Compute(dup[0])

        let skippedClosing = Skip(dup[1], IdlePeriod())
        let smaDelayed = SkipLast(smaOut, k)

        return Operate(skippedClosing, smaDelayed, { price: Float64, shifted: Float64 =>
            return price - shifted
        })
    }

    public func IdlePeriod(): Int64 {
        return (Period - 1) + (Period / 2 + 1)
    }

    public func toString(): String { return "DPO(${Period})" }
}

public func NewDpo(): Dpo { return Dpo() }
public func NewDpoWithPeriod(period: Int64): Dpo { return Dpo(period) }


