package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * StochasticOscillator 随机振荡器指标
 *
 * 计算公式：
 * - %K = 100 * (收盘价 - N周期最低价) / (N周期最高价 - N周期最低价)
 * - %D = SMA(%K, 周期)
 *
 * 详细说明：
 * 该指标用于衡量价格在给定周期内的相对位置。
 * 通过计算收盘价在价格区间中的位置，判断超买超卖状态。
 *
 * 特点：
 * - 范围限制：%K值在0-100之间波动
 * - 超买超卖：%K高于80为超买，低于20为超卖
 * - 双线系统：%K快线和%D慢线交叉产生信号
 *
 * 交易信号：
 * - 超买区：%K > 80，可能回调
 * - 超卖区：%K < 20，可能反弹
 * - 金叉：%K上穿%D为买入信号
 * - 死叉：%K下穿%D为卖出信号
 *
 * 常用参数：
 * - 快线周期：14天
 * - 慢线平滑：3天或5天
 *
 * 创建者：George Lane（乔治·莱恩）
 * 创建时间：1950年代
 *
 * 注意事项：
 * - 在强趋势中可能长期处于超买或超卖区
 * - 适合震荡市场，趋势市场需配合其他指标
 */
public class StochasticOscillator {
    /**
     * period 计算周期
     *
     * 默认值：STOCHASTIC_DEFAULT_PERIOD
     * 用途：确定%K计算的时间窗口
     */
    public var period: Int64 = STOCHASTIC_DEFAULT_PERIOD

    /**
     * 默认构造函数
     *
     * 使用默认周期初始化振荡器
     */
    public StochasticOscillator() {
        // 使用默认值
    }

    /**
     * 带参数构造函数
     *
     * @param period 计算周期
     */
    public init(period: Int64) {
        this.period = period
    }

    /**
     * compute 计算随机振荡器指标值
     *
     * 计算步骤：
     * 1. 计算N周期内的最高价和最低价
     * 2. 计算%K = 100 * (收盘价 - 最低价) / (最高价 - 最低价)
     * 3. 计算%D = SMA(%K, period)
     *
     * @param highs 最高价迭代器
     * @param lows 最低价迭代器
     * @param closes 收盘价迭代器
     * @return 二元组，依次为：
     *         - %K值迭代器（0-100之间）
     *         - %D值迭代器（%K的平滑值）
     */
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let hh = MovingMax(period).compute(highs)
        let ll = MovingMin(period).compute(lows)
        let closeAdj = skip(closes, period - 1)

        let k = multiplyBy(
            divide(
                subtract(closeAdj, ll),
                subtract(hh, ll)
            ),
            100.0
        )

        let sma = Sma()
        sma.period = period
        let d = sma.compute(k)

        return (k, d)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period-1），前(period-1)个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return period - 1 }
}

