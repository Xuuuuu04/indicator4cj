package indicator4cj.trend

import std.core.*

public const DefaultTrimaPeriod: Int64 = 15

// Triangular Moving Average (TRIMA)
public class Trima {
    public var Period: Int64

    public init() {
        this.Period = DefaultTrimaPeriod
    }

    public init(period: Int64) {
        this.Period = period
    }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let (p1, p2) = calculatePeriods()
        let sma1 = Sma(p1)
        let sma2 = Sma(p2)
        return sma1.compute(sma2.compute(c))
    }

    public func idlePeriod(): Int64 {
        let (p1, p2) = calculatePeriods()
        return p1 + p2 - 2
    }

    private func calculatePeriods(): (Int64, Int64) {
        var p1: Int64
        var p2: Int64
        if (Period % 2 == 0) {
            p1 = Period / 2
            p2 = p1 + 1
        } else {
            p1 = (Period + 1) / 2
            p2 = p1
        }
        return (p1, p2)
    }

    public func toString(): String { return "TRIMA(${Period})" }
}

