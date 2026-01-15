package indicator4cj.volatility

import std.core.*
import std.math.*
import indicator4cj.helper.*

// Moving Standard Deviation over fixed period (Float64).
public class MovingStd {
    public var period: Int64

    public init() { this.period = 1 }
    public init(period: Int64) { this.period = period }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return MovingStdIterator(c, this.period)
    }

    public func idlePeriod(): Int64 { return this.period - 1 }
}

// Iterator maintaining ring buffer and running mean.
private class MovingStdIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private let _ring: Ring<Float64>
    private var _sum: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
        this._ring = Ring<Float64>(period)
    }

    public func next(): Option<Float64> {
        match (_source.next()) {
            case Some(v) =>
                let dropped = _ring.Put(v)
                match (dropped) {
                    case Some(old) => _sum = _sum - old + v
                    case None => _sum = _sum + v
                }

                if (_ring.IsFull()) {
                    let sma = _sum / Float64(_period)
                    var sum2 = 0.0
                    var i: Int64 = 0
                    while (i < _period) {
                        let diff = _ring.At(i) - sma
                        sum2 += pow(diff, 2.0)
                        i = i + 1
                    }
                    let std = sqrt(sum2 / Float64(_period))
                    return Some(std)
                }
                return next()
            case None => return None
        }
    }
}

