package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * Sma 简单移动平均线指标
 *
 * 计算公式：SMA = (P1 + P2 + ... + Pn) / n
 *
 * 详细说明：
 * 其中 P 为价格，n 为周期。对所有数据点给予相同权重进行算术平均。
 *
 * 特点：
 * - 权重均等：所有数据点权重相同
 * - 计算简单：易于理解和计算
 * - 滞后性：对近期价格变化反应较慢
 * - 稳定性好：不易受短期价格波动影响
 *
 * 用途：
 * - 识别趋势方向：价格在SMA上方为上升趋势，反之为下降趋势
 * - 生成支撑/阻力位：SMA常作为动态支撑或阻力
 * - 价格交叉信号：金叉（短周期上穿长周期）为买入信号
 * - 过滤噪音：平滑价格波动，显示主要趋势
 *
 * 交易信号：
 * - 金叉：短期SMA上穿长期SMA，买入信号
 * - 死叉：短期SMA下穿长期SMA，卖出信号
 * - 价格突破：价格突破SMA可能预示趋势改变
 *
 * 注意事项：
 * - 具有滞后性，不适合捕捉短期转折点
 * - 在震荡市场中可能产生较多假信号
 * - 常用周期：SMA20（短期）、SMA50（中期）、SMA200（长期）
 */
public class Sma {
    /**
     * period 移动平均线周期
     *
     * 默认值：MA_DEFAULT_PERIOD
     * 必须大于0
     * 用途：确定计算平均值的窗口大小
     */
    public var period: Int64 = MA_DEFAULT_PERIOD

    public init() {
        // 使用默认值
    }

    /**
     * 带参数构造函数
     *
     * @param period 移动平均线周期，必须大于0
     * @throws Exception 如果周期小于等于0
     */
    public init(period: Int64) {
        if (period <= 0) {
            throw Exception("[SMA] period must be positive, got ${period}")
        }
        this.period = period
    }

    /**
     * compute 计算简单移动平均线
     *
     * 计算方法：对指定周期内的价格数据进行算术平均。
     * 使用 MovingSum 辅助函数计算窗口内的总和，然后除以周期数。
     *
     * @param values 价格数据迭代器
     * @return SMA值迭代器，前(period-1)个数据点无输出
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let sum = MovingSum()
        sum.period = period
        return divideBy(sum.compute(values), Float64(period))
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
     * @return 格式为 "SMA(period)" 的字符串
     */
    public func toString(): String { return "SMA(${period})" }
}

