package indicator4cj.volatility

import std.core.*
import std.math.*
import indicator4cj.helper.*

// Moving Standard Deviation over fixed period (Float64).
public class MovingStd {
    // 周期
    public var period: Int64 = 1

    public init() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算移动标准差指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return MovingStdIterator(c, this.period)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}

// Iterator maintaining ring buffer and running mean.
private class MovingStdIterator <: Iterator<Float64> {
    private let source: Iterator<Float64>
    private let period: Int64
    private let ring: Ring<Float64>
    private var sum: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this.source = source
        this.period = period
        this.ring = Ring<Float64>(period)
    }

    public func next(): Option<Float64> {
        match (source.next()) {
            case Some(v) =>
                let dropped = ring.Put(v)
                match (dropped) {
                    case Some(old) => sum = sum - old + v
                    case None => sum = sum + v
                }

                if (ring.IsFull()) {
                    let sma = sum / Float64(period)
                    var sum2 = 0.0
                    var i: Int64 = 0
                    while (i < period) {
                        let diff = ring.At(i) - sma
                        sum2 += pow(diff, 2.0)
                        i = i + 1
                    }
                    let std = sqrt(sum2 / Float64(period))
                    return Some(std)
                }
                return next()
            case None => return None
        }
    }
}

