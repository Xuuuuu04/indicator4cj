package indicator4cj.trend

import std.core.*
// no collection import needed

// Exponential Moving Average (Float64).
public class Ema {
    public var Period: Int64
    public var Smoothing: Float64

    public init() {
        this.Period = 20
        this.Smoothing = 2.0
    }

    public init(period: Int64) {
        this.Period = period
        this.Smoothing = 2.0
    }

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        return EmaIterator(c, Period, Smoothing)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }

    public func toString(): String { return "EMA(${Period})" }
}

private class EmaIterator <: Iterator<Float64> {
    private let source: Iterator<Float64>
    private let period: Int64
    private let multiplier: Float64
    private var seeded: Bool = false
    private var prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64, smoothing: Float64) {
        this.source = source
        this.period = period
        this.multiplier = smoothing / Float64(period + 1)
    }

    public func next(): Option<Float64> {
        if (!seeded) {
            var sum = 0.0
            var count: Int64 = 0
            while (count < period) {
                match (source.next()) {
                    case Some(v) =>
                        sum += v
                        count += 1
                    case None =>
                        return None
                }
            }
            prev = sum / Float64(period)
            seeded = true
            return Some(prev)
        }

        match (source.next()) {
            case Some(v) =>
                prev = (v - prev) * multiplier + prev
                return Some(prev)
            case None => return None
        }
    }
}

