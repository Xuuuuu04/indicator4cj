package indicator4cj.trend

import std.core.*
import std.collection.*

// Weighted Moving Average (WMA) for Float64.
public class Wma {
    public var period: Int64

    public init(period: Int64) {
        if (period <= 0) { throw Exception("period must be > 0") }
        this.period = period
    }

    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return WmaIterator(values, this.period)
    }

    public func idlePeriod(): Int64 { return this.period - 1 }
}

private class WmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private let _buffer = ArrayList<Float64>()
    private let _divisor: Float64

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
        this._divisor = Float64(period) * (Float64(period) + 1.0) / 2.0
    }

    public func next(): Option<Float64> {
        while (true) {
            match (_source.next()) {
                case Some(v) =>
                    _buffer.add(v)
                    if (_buffer.size < _period) {
                        continue
                    }
                    if (_buffer.size > _period) {
                        _buffer.remove(at: 0)
                    }
                    var sum = 0.0
                    var i: Int64 = 0
                    while (i < _period) {
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
                        let weight = Float64(_period - i)
                        sum += _buffer[i] * weight
                        i += 1
                    }
                    return Some(sum / _divisor)
                case None => return None
            }
        }
        return None
    }
}

// Wma conforms to Ma.
extend Wma <: Ma {}