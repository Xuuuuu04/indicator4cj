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
    private let source: Iterator<Float64>
    private let period: Int64
    private var initialized: Bool = false
    private var prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this.source = source
        this.period = period
    }

    public func next(): Option<Float64> {
        // Initial SMA over first period elements.
        if (!initialized) {
            let buf = ArrayList<Float64>()
            while (buf.size < period) {
                match (source.next()) {
                    case Some(v) => buf.add(v)
                    case None => return None
                }
            }
            var sum: Float64 = 0.0
            for (v in buf) { sum += v }
            prev = sum / Float64(period)
            initialized = true
            return Some(prev)
        }

        match (source.next()) {
            case Some(v) =>
                prev = (prev * Float64(period - 1) + v) / Float64(period)
                return Some(prev)
            case None => return None
        }
    }
}


