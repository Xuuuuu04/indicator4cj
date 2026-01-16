package indicator4cj.trend

import std.core.*
import std.collection.*

// Weighted Moving Average (WMA) for Float64.
public class Wma {
    // 周期
    public var period: Int64 = 20

    public init(period: Int64) {
        if (period <= 0) { throw Exception("period must be > 0") }
        this.period = period
    }

    public Wma() {
        this.period = period
    }

    // compute 计算加权移动平均线。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return WmaIterator(values, this.period)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}

private class WmaIterator <: Iterator<Float64> {
    private let source: Iterator<Float64>
    private let period: Int64
    private let buffer = ArrayList<Float64>()
    private let divisor: Float64

    public init(source: Iterator<Float64>, period: Int64) {
        this.source = source
        this.period = period
        this.divisor = Float64(period) * (Float64(period) + 1.0) / 2.0
    }

    public func next(): Option<Float64> {
        while (true) {
            match (source.next()) {
                case Some(v) =>
                    buffer.add(v)
                    if (buffer.size < period) {
                        continue
                    }
                    if (buffer.size > period) {
                        buffer.remove(at: 0)
                    }
                    var sum = 0.0
                    var i: Int64 = 0
                    while (i < period) {
                        // The weights should be: newest (index period-1) has weight 'period'
                        // oldest (index 0) has weight '1'
                        // Formula: (P*D_t + (P-1)*D_{t-1} + ... + 1*D_{t-P+1}) / Divisor
                        // buffer[period-1] is current (D_t)
                        // buffer[0] is oldest (D_{t-P+1})

                        // My loop: i goes 0 to period-1.
                        // buffer[i]
                        // If i=0 (oldest), weight should be 1?
                        // If i=period-1 (newest), weight should be period?

                        // Current code:
                        // let weight = Float64(period - i)
                        // i=0 -> weight=period. (Oldest gets max weight? Wrong!)
                        // i=period-1 -> weight=1. (Newest gets min weight? Wrong!)

                        // Match Go implementation: Oldest gets highest weight (Period).
                        let weight = Float64(period - i)
                        sum += buffer[i] * weight
                        i += 1
                    }
                    return Some(sum / divisor)
                case None => return None
            }
        }
        return None
    }
}

// Wma conforms to Ma.
extend Wma <: Ma {}