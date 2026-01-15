package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultDpoPeriod: Int64 = 20

// Detrended Price Oscillator (DPO)
public class Dpo {
    public var period: Int64

    public init() { this.period = DefaultDpoPeriod }
    public init(period: Int64) {
        if (period <= 1) {
            this.period = DefaultDpoPeriod
        } else {
            this.period = period
        }
    }

    public func compute(closing: Iterator<Float64>): Iterator<Float64> {
        let k = this.period / 2 + 1
        let dup = Duplicate(closing, 2)

        let sma = Sma()
        sma.period = this.period
        let smaOut = sma.compute(dup[0])

        let skippedClosing = Skip(dup[1], idlePeriod())
        let smaDelayed = SkipLast(smaOut, k)

        return Operate(skippedClosing, smaDelayed, { price: Float64, shifted: Float64 =>
            return price - shifted
        })
    }

    public func idlePeriod(): Int64 {
        return (this.period - 1) + (this.period / 2 + 1)
    }

    public func toString(): String { return "DPO(${this.period})" }
}

