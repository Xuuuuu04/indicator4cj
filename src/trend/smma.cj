package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultSmmaPeriod: Int64 = 7

// 平滑移动平均线（SMMA）
public class Smma {
    // 周期
    public var period: Int64 = DefaultSmmaPeriod

    public Smma() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return SmmaIterator(c, period)
    }

    public func idlePeriod(): Int64 { return period - 1 }

    public func toString(): String { return "SMMA(${period})" }
}

private class SmmaIterator <: Iterator<Float64> {
    private let source: Iterator<Float64>
    private let period: Int64
    private var initialized: Bool = false
    private var prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this.source = source
        this.period = period
    }

    public func next(): Option<Float64> {
        if (!initialized) {
            let head = Head(source, period)
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
            if (count < period) {
                return None
            }
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
