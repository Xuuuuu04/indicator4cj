package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * Ema 指数移动平均线指标
 *
 * 计算公式：EMA = Price * k + PreviousEMA * (1 - k)
 * 其中 k = smoothing / (period + 1)，通常 smoothing = 2
 *
 * 详细说明：
 * 给予近期数据更高权重，对价格变化反应更灵敏。
 * 权重按指数递减，最近的权重最大，历史数据权重逐渐减小。
 *
 * 特点：
 * - 加权平均：近期价格权重更高，历史价格权重指数递减
 * - 反应灵敏：相比SMA对价格变化反应更快
 * - 滞后较小：滞后性明显小于SMA
 * - 基础指标：是MACD、KDJ等指标的基础
 *
 * 用途：
 * - 趋势跟踪：短期EMA用于捕捉短期趋势
 * - 交叉信号：EMA交叉系统比SMA更灵敏
 * - 支撑阻力：动态支撑和阻力位
 * - 指标构建：作为其他指标的计算基础
 *
 * 交易信号：
 * - EMA交叉：短期EMA上穿长期EMA为买入信号
 * - 价格突破：价格突破EMA可能预示趋势改变
 * - 斜率判断：EMA向上表明上升趋势，向下表明下降趋势
 *
 * 优势：
 * - 比SMA更灵敏，适合短线交易
 * - 减少滞后，更贴近价格走势
 *
 * 劣势：
 * - 可能产生更多假信号
 * - 在震荡市场中容易频繁交叉
 *
 * 常用周期：
 * - EMA12、EMA26：MACD指标常用
 * - EMA50：中期趋势判断
 * - EMA200：长期趋势支撑/阻力
 */
public class Ema {
    /**
     * period EMA周期
     *
     * 默认值：EMA_DEFAULT_PERIOD
     * 用途：确定平滑系数的窗口大小
     */
    public var period: Int64 = EMA_DEFAULT_PERIOD

    /**
     * smoothing 平滑系数
     *
     * 默认值：EMA_DEFAULT_SMOOTHING（通常为2）
     * 用途：计算权重系数 k = smoothing / (period + 1)
     */
    public var smoothing: Float64 = EMA_DEFAULT_SMOOTHING

    /**
     * 默认构造函数
     *
     * 使用默认周期和平滑系数初始化EMA
     */
    public init() {
        // 使用默认值
    }

    /**
     * 带参数构造函数
     *
     * @param period EMA周期
     */
    public init(period: Int64) {
        this.period = period
        // 使用默认平滑系数（通常为2.0）
        this.smoothing = EMA_DEFAULT_SMOOTHING
    }

    /**
     * compute 计算指数移动平均线
     *
     * 计算方法：
     * 1. 使用前period个数据点的SMA作为种子值
     * 2. 之后每个新值按公式：EMA = Price * k + PreviousEMA * (1 - k)
     *
     * @param values 价格数据迭代器
     * @return EMA值迭代器
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return EmaIterator(values, period, smoothing)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period-1），前(period-1)个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return period - 1 }

    /**
     * toString 返回指标的字符串表示
     *
     * @return 格式为 "EMA(period)" 的字符串
     */
    public func toString(): String { return "EMA(${period})" }
}

/**
 * EmaIterator EMA迭代器实现
 *
 * 内部迭代器类，实现指数移动平均的具体计算逻辑。
 */
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

