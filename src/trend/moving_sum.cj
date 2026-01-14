package indicator4cj.trend

import std.core.*
import std.collection.*

// Moving Sum over a fixed period (Float64 version).
public class MovingSum {
    public var Period: Int64

    public init() { this.Period = 1 }
    public init(period: Int64) { this.Period = period }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return MovingSumIterator(c, Period)
    }

    public func idlePeriod(): Int64 { return Period - 1 }
}

private class MovingSumIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private var _buffer: ArrayList<Float64>
    private var _initialized: Bool = false
    private var _sum: Float64 = 0.0
    private var _index: Int64 = 0

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
        this._buffer = ArrayList<Float64>()
    }

    public func next(): Option<Float64> {
        while (_buffer.size < _period) {
            match (_source.next()) {
                case Some(v) =>
                    _buffer.add(v)
                    _sum += v
                case None => return None
            }
        }

        // First emission after filling buffer.
        if (!_initialized) {
            _initialized = true
            return Some(_sum)
        }

        // Slide window: drop oldest, add next.
        match (_source.next()) {
            case Some(v) =>
                let old = _buffer[0]
                _buffer.remove(at: 0)
                _buffer.add(v)
                _sum = _sum - old + v
                return Some(_sum)
            case None => return None
        }
    }
}

