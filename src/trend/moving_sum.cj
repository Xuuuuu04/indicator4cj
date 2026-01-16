package indicator4cj.trend

import std.core.*
import std.collection.*

// 固定周期移动求和（Float64 版本）。
public class MovingSum {
    // 周期
    public var period: Int64 = 1

    public MovingSum() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

// compute 计算指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        return MovingSumIterator(c, period)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
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

        // 缓冲区填满后的首次输出。
        if (!initialized) {
            initialized = true
            return Some(sum)
        }

        // 滑动窗口：移除最旧的，添加下一个。
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
