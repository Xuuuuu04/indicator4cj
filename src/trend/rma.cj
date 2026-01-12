package indicator4cj.trend

import std.core.*
import std.collection.*

// Rolling Moving Average (RMA) with Wilder smoothing.
public class Rma {
    public var Period: Int64

    public init() { this.Period = 20 }
    public init(period: Int64) { this.Period = period }

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        return RmaIterator(c, Period)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

private class RmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private var _initialized: Bool = false
    private var _prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
    }

    public func next(): Option<Float64> {
        // Initial SMA over first period elements.
        if (!_initialized) {
            let buf = ArrayList<Float64>()
            while (buf.size < _period) {
                match (_source.next()) {
                    case Some(v) => buf.add(v)
                    case None => return None
                }
            }
            var sum: Float64 = 0.0
            for (v in buf) { sum += v }
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


