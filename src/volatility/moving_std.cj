package indicator4cj.volatility

import std.core.*
import std.math.*
import indicator4cj.helper.*

// 固定周期移动标准差（Float64）。
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
        return MovingStdIterator(c, period)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

// 维护环形缓冲区和运行均值的迭代器。
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

