package indicator4cj.trend

import std.core.*
import std.collection.*

// 滚动移动平均线（RMA），使用 Wilder 平滑。
public class Rma {
    // 周期
    public var period: Int64 = 20

    public Rma() {
        // 使用默认值 20
    }

    public init(period: Int64) {
        this.period = period
    }

/**
 * compute 计算滚动移动平均线
 *
 * 计算RMA（Rolling Moving Average），使用Wilder平滑方法。
 * 与EMA类似但平滑公式不同。
 *
 * @param values 价格数据迭代器
 * @return RMA值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return RmaIterator(values, period)
    }

    public func idlePeriod(): Int64 { return period - 1 }
}

private class RmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private var _initialized: Bool = false
    private var _prev: Float64 = 0.0

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
    }

    public func next(): Option<Float64> {
        // 初始 SMA 覆盖首个周期元素。
        if (!_initialized) {
            let buf = ArrayList<Float64>()
            while (buf.size < _period) {
                match (_source.next()) {
                    case Some(v) => buf.add(v)
                    case None => return None
                }
            }
            var sum: Float64 = 0.0
            for (v in buf) { sum += v }
            _prev = sum / Float64(_period)
            _initialized = true
            return Some(_prev)
        }

        match (_source.next()) {
            case Some(v) =>
                _prev = (_prev * Float64(_period - 1) + v) / Float64(_period)
                return Some(_prev)
            case None => return None
        }
    }
}
