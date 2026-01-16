package indicator4cj.trend

import std.core.*
import std.collection.*

// Moving Sum over a fixed period (Float64 version).
public class MovingSum {
    public var period: Int64 = 1

    public MovingSum() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

// compute 计算指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return MovingSumIterator(c, this.period)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}

private class MovingSumIterator <: Iterator<Float64> {
    private let source: Iterator<Float64>
    private let period: Int64
    private var buffer: ArrayList<Float64>
    private var initialized: Bool = false
    private var sum: Float64 = 0.0
    private var index: Int64 = 0

    public init(source: Iterator<Float64>, period: Int64) {
        this.source = source
        this.period = period
        this.buffer = ArrayList<Float64>()
    }

    public func next(): Option<Float64> {
        while (buffer.size < period) {
            match (source.next()) {
                case Some(v) =>
                    buffer.add(v)
                    sum += v
                case None => return None
            }
        }

        // First emission after filling buffer.
        if (!initialized) {
            initialized = true
            return Some(sum)
        }

        // Slide window: drop oldest, add next.
        match (source.next()) {
            case Some(v) =>
                let old = buffer[0]
                buffer.remove(at: 0)
                buffer.add(v)
                sum = sum - old + v
                return Some(sum)
            case None => return None
        }
    }
}
