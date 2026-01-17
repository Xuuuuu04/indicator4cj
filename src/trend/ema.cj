package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * Ema 指数移动平均线指标
 *
 * 计算指数移动平均线(EMA)，给予近期数据更高权重。
 */
public class Ema {
    /** 周期 */
    public var period: Int64 = EMA_DEFAULT_PERIOD
    /** 平滑系数 */
    public var smoothing: Float64 = EMA_DEFAULT_SMOOTHING

    public init() {
        // 使用默认值
    }

    public init(period: Int64) {
        this.period = period
        this.smoothing = smoothing
    }

/**
 * compute 计算指数移动平均线
 *
 * 计算指数移动平均线(EMA)，给予近期数据更高权重。
 *
 * @param values 价格数据迭代器
 * @return EMA值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return EmaIterator(values, period, smoothing)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }

    // toString 返回指标的字符串表示。
    public func toString(): String { return "EMA(${period})" }
}

private class EmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private let _multiplier: Float64
    private var _seeded: Bool = false
    private var _prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64, smoothing: Float64) {
        this._source = source
        this._period = period
        _multiplier = smoothing / Float64(period + 1)
    }

    public func next(): Option<Float64> {
        if (!_seeded) {
            var sum = 0.0
            var count: Int64 = 0
            while (count < _period) {
                match (_source.next()) {
                    case Some(v) =>
                        sum += v
                        count += 1
                    case None =>
                        return None
                }
            }
            _prev = sum / Float64(_period)
            _seeded = true
            return Some(_prev)
        }

        match (_source.next()) {
            case Some(v) =>
                _prev = (v - _prev) * _multiplier + _prev
                return Some(_prev)
            case None => return None
        }
    }
}

