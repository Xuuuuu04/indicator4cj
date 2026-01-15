package indicator4cj.trend

import std.core.*
// no collection import needed

// Exponential Moving Average (Float64).
public class Ema {
    public var period: Int64
    public var smoothing: Float64

    public init() {
        this.period = 20
        this.smoothing = 2.0
    }

    public init(period: Int64) {
        this.period = period
        this.smoothing = 2.0
    }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return EmaIterator(c, this.period, this.smoothing)
    }

    public func idlePeriod(): Int64 { return this.period - 1 }

    public func toString(): String { return "EMA(${this.period})" }
}

private class EmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private let _multiplier: Float64
    private var _seeded: Bool = false
    private var _prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64, smoothing: Float64) {
        this._source = source
        this._period = period
        this._multiplier = smoothing / Float64(period + 1)
    }

    public func next(): Option<Float64> {
        if (!_seeded) {
            var sum = 0.0
            var count: Int64 = 0
            while (count < _period) {
                match (_source.next()) {
                    case Some(v) =>
                        sum += v
                        count += 1
                    case None =>
                        return None
                }
            }
            _prev = sum / Float64(_period)
            _seeded = true
            return Some(_prev)
        }

        match (_source.next()) {
            case Some(v) =>
                _prev = (v - _prev) * _multiplier + _prev
                return Some(_prev)
            case None => return None
        }
    }
}

