package indicator4cj.trend

import std.core.*
import std.collection.*

// 加权移动平均线（WMA）（Float64）。
public class Wma {
    // 周期
    public var period: Int64 = 20

    public init(period: Int64) {
        if (period <= 0) { throw Exception("period must be > 0") }
        this.period = period
    }

    public Wma() {
        this.period = period
    }

    // compute 计算加权移动平均线。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return WmaIterator(values, period)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

private class WmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private let _buffer = ArrayList<Float64>()
    private let _divisor: Float64

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
        this._divisor = Float64(period) * (Float64(period) + 1.0) / 2.0
    }

    public func next(): Option<Float64> {
        while (true) {
            match (_source.next()) {
                case Some(v) =>
                    _buffer.add(v)
                    if (_buffer.size < _period) {
                        continue
                    }
                    if (_buffer.size > _period) {
                        _buffer.remove(at: 0)
                    }
                    var sum = 0.0
                    var i: Int64 = 0
                    while (i < _period) {
                        // 权重应该是：最新的（索引 period-1）具有权重 'period'
                        // 最旧的（索引 0）具有权重 '1'
                        // 公式：(P*D_t + (P-1)*D_{t-1} + ... + 1*D_{t-P+1}) / 除数
                        // buffer[period-1] 是当前（D_t）
                        // buffer[0] 是最旧的（D_{t-P+1}）

                        // 我的循环：i 从 0 到 period-1。
                        // buffer[i]
                        // 如果 i=0（最旧），权重应该是 1？
                        // 如果 i=period-1（最新），权重应该是 period？

                        // 当前代码：
                        // let weight = Float64(period - i)
                        // i=0 -> weight=period。（最旧获得最大权重？错误！）
                        // i=period-1 -> weight=1。（最新获得最小权重？错误！）

                        // 匹配 Go 实现：最旧的获得最高权重（周期）。
                        let weight = Float64(_period - i)
                        sum += _buffer[i] * weight
                        i += 1
                    }
                    return Some(sum / _divisor)
                case None => return None
            }
        }
        return None
    }
}

// Wma 符合 Ma 接口。
extend Wma <: Ma {}