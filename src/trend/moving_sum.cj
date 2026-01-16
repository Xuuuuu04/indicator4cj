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

        // 缓冲区填满后的首次输出。
        if (!_initialized) {
            _initialized = true
            return Some(_sum)
        }

        // 滑动窗口：移除最旧的，添加下一个。
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
