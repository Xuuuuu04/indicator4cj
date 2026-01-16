package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultDpoPeriod: Int64 = 20

// Detrended Price Oscillator (DPO)
public class Dpo {
    // 周期
    public var period: Int64 = DefaultDpoPeriod

    public Dpo() {
        this.period = period
    }
    public init(period: Int64) {
        if (period <= 1) {
            this.period = DefaultDpoPeriod
        } else {
            this.period = period
        }
    }

// compute 计算指标。
    public func compute(closing: Iterator<Float64>): Iterator<Float64> {
        let k = period / 2 + 1
        let dup = Duplicate(closing, 2)

        let sma = Sma()
        sma.period = period
        let smaOut = sma.compute(dup[0])

        let skippedClosing = Skip(dup[1], idlePeriod())
        let smaDelayed = SkipLast(smaOut, k)

        return Operate(skippedClosing, smaDelayed, { price: Float64, shifted: Float64 =>
            return price - shifted
        })
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return (period - 1) + (period / 2 + 1)
    }

// toString 返回指标的字符串表示。
    public func toString(): String { return "DPO(${period})" }
}
