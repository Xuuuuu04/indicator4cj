package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * BollingerBands 布林带指标
 *
 * 计算公式：
 * - 中轨 = SMA(price, period)
 * - 上轨 = 中轨 + k * StdDev(price, period)
 * - 下轨 = 中轨 - k * StdDev(price, period)
 *
 * 详细说明：
 * 由三条线组成的技术分析工具，由 John Bollinger 在1980年代创建。
 * 基于统计学的标准差原理，用于衡量价格波动率和超买超卖状态。
 *
 * 核心概念：
 * - 中轨：简单移动平均线（SMA），通常为20周期
 * - 标准差：衡量价格波动率
 * - 倍数k：通常为2，表示上下轨距离中轨的标准差倍数
 *
 * 特点：
 * - 动态调整：带宽随波动率变化
 * - 统计基础：基于正态分布理论（约95%数据在±2标准差内）
 * - 波动率指示：带宽反映市场波动率
 * - 趋势跟踪：中轨反映趋势方向
 *
 * 用途：
 * - 超买超卖判断：价格触及上下轨可能预示反转
 * - 突破交易：价格突破布林带可能预示强趋势
 * - 波动率分析：带宽收窄预示突破，带宽扩大表示高波动
 * - 趋势确认：价格在中轨上方为上涨趋势
 *
 * 交易信号：
 * - 价格触及上轨：可能的超买信号
 * - 价格触及下轨：可能的超卖信号
 * - 布林带收缩（Squeeze）：预示即将突破
 * - 价格突破中轨：趋势改变信号
 *
 * 创建者：John Bollinger（约翰·布林格）
 * 创建时间：1980年代
 *
 * 参数说明：
 * - period：通常为20（可调整10-50）
 * - k：通常为2（可调整1.5-2.5）
 *
 * 注意事项：
 * - 在强趋势中，价格可能持续在带外运行
 * - 配合其他指标使用效果更佳（如RSI、MACD）
 * - 横盘市场中的假信号较多
 */
public class BollingerBands {
    /**
     * period 布林带周期
     *
     * 默认值：BOLLINGER_BANDS_DEFAULT_PERIOD（通常为20）
     * 用途：计算SMA和标准差的时间窗口
     */
    public var period: Int64 = BOLLINGER_BANDS_DEFAULT_PERIOD

    /**
     * 默认构造函数
     *
     * 使用默认周期20初始化布林带
     */
    public BollingerBands() {
        // 使用默认值 20
    }

    /**
     * 带参数构造函数
     *
     * @param period 布林带周期
     */
    public init(period: Int64) {
        this.period = period
    }

    /**
     * compute 计算布林带指标
     *
     * 计算步骤：
     * 1. 计算中轨：SMA(price, period)
     * 2. 计算标准差：StdDev(price, period)
     * 3. 计算上轨：中轨 + k * 标准差（k通常为2）
     * 4. 计算下轨：中轨 - k * 标准差
     *
     * @param values 价格数据迭代器
     * @return 三元组，依次为：
     *         - 上轨迭代器（Upper Band）
     *         - 中轨迭代器（Middle Band，即SMA）
     *         - 下轨迭代器（Lower Band）
     */
    public func compute(values: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let duplicatedValues = duplicate(values, 2)
        let sma = Sma()
        sma.period = period
        let std = MovingStd()
        std.period = period

        let middleBands = duplicate(
            sma.compute(duplicatedValues[0]),
            3
        )

        let stdDeviations = duplicate(
            multiplyBy(std.compute(duplicatedValues[1]), BOLLINGER_BANDS_MULTIPLIER),
            2
        )

        let upperBand = add(middleBands[0], stdDeviations[0])
        let lowerBand = subtract(middleBands[1], stdDeviations[1])

        return (upperBand, middleBands[2], lowerBand)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period-1），前(period-1)个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return period - 1 }
}

