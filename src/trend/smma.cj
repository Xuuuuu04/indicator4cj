package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultSmmaPeriod: Int64 = 7

// Smoothed Moving Average (SMMA)
public class Smma {
    public var period: Int64

    public Smma() {
        this.period = DefaultSmmaPeriod
    }

    public init(period: Int64) {
        this.period = period
    }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return SmmaIterator(c, this.period)
    }

    public func idlePeriod(): Int64 { return this.period - 1 }

    public func toString(): String { return "SMMA(${this.period})" }
}

private class SmmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private var _initialized: Bool = false
    private var _prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
    }

    public func next(): Option<Float64> {
        if (!_initialized) {
            let head = Head(_source, _period)
            var sum: Float64 = 0.0
            var count: Int64 = 0
            while (true) {
                match (head.next()) {
                    case Some(v) =>
                        sum += v
                        count += 1
                    case None => break
                }
            }
            if (count < _period) {
                return None
            }
            _prev = sum / Float64(_period)
            _initialized = true
            return Some(_prev)
        }

        match (_source.next()) {
            case Some(v) =>
                _prev = (_prev * Float64(_period - 1) + v) / Float64(_period)
                return Some(_prev)
            case None => return None
        }
    }
}

