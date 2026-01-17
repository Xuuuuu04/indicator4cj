package indicator4cj.trend

import std.core.*
import std.collection.*
import indicator4cj.helper.*

/**
 * Rma 滚动移动平均线（Rolling Moving Average）
 *
 * 计算公式：RMA = (PrevRMA * (period - 1) + Price) / period
 *
 * 详细说明：
 * 使用 Wilder 平滑方法，也称为 Wilder's Smoothing 或 Wilder's RMA。
 * 这是一种特殊的指数平滑方法，由 J. Welles Wilder Jr. 创建。
 *
 * 特点：
 * - Wilder平滑：使用特定的平滑公式
 * - 权重递减：历史数据权重逐渐减小，但递减速度比EMA慢
 * - 初值SMA：第一个值使用SMA作为种子
 * - 平滑稳定：相比EMA更加平滑稳定
 *
 * 与EMA的区别：
 * - EMA: alpha = 2 / (period + 1)
 * - RMA: alpha = 1 / period
 * - RMA的平滑系数更小，因此反应更慢，曲线更平滑
 *
 * 用途：
 * - RSI计算：RSI指标使用RMA计算平均涨跌幅
 * - ATR计算：平均真实波幅常用RMA
 * - 趋势过滤：适合需要更平滑曲线的场景
 *
 * 优势：
 * - 极其平滑，噪音小
 * - 计算简单高效
 * - 适合作为其他指标的组成部分
 *
 * 劣势：
 * - 滞后性较大
 * - 不适合短线交易
 *
 * 创建者：J. Welles Wilder Jr.
 * 出处：《New Concepts in Technical Trading Systems》（1978年）
 *
 * 注意事项：
 * - RSI和ATR等指标的标准计算方法使用RMA而非EMA
 * - 周期相同时，RMA比EMA慢
 */
public class Rma {
    /**
     * period RMA周期
     *
     * 默认值：RMA_DEFAULT_PERIOD
     * 用途：确定平滑系数的大小
     */
    public var period: Int64 = RMA_DEFAULT_PERIOD

    /**
     * 默认构造函数
     *
     * 使用默认周期初始化RMA
     */
    public Rma() {
        // 使用默认值
    }

    /**
     * 带参数构造函数
     *
     * @param period RMA周期
     */
    public init(period: Int64) {
        this.period = period
    }

    /**
     * compute 计算滚动移动平均线
     *
     * 计算方法：
     * 1. 第一个值：使用前period个数据点的SMA
     * 2. 后续值：RMA = (PrevRMA * (period - 1) + Price) / period
     *
     * @param values 价格数据迭代器
     * @return RMA值迭代器
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return RmaIterator(values, period)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period-1）
     */
    public func idlePeriod(): Int64 { return period - 1 }
}

/**
 * RmaIterator RMA迭代器实现
 *
 * 内部迭代器类，实现Wilder平滑的具体计算逻辑。
 */
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
