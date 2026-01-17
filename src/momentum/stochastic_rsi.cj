package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * StochasticRsi 随机RSI指标
 *
 * 计算公式：StochRSI = (RSI - Lowest RSI) / (Highest RSI - Lowest RSI)
 *
 * 详细说明：
 * 将RSI指标应用于随机振荡器方法，产生0-100之间的值。
 * 相比普通RSI，Stochastic RSI 对超买超卖区域更敏感。
 *
 * 特点：
 * - 双重指标：先计算RSI，再对RSI序列应用随机振荡器
 * - 固定范围：值始终在0-100之间
 * - 更敏感：相比RSI产生更多的交易信号
 *
 * 交易信号：
 * - 超买区域：StochRSI > 80，可能回调
 * - 超卖区域：StochRSI < 20，可能反弹
 * - 交叉信号：快线上穿慢线为买入信号
 * - 中心交叉：从超卖区回到50以上为强势信号
 *
 * 相关指标：
 * - 基础指标：RSI（Relative Strength Index）
 * - 类似方法：Stochastic Oscillator
 *
 * 注意事项：
 * - 产生的信号较多，需要配合其他指标过滤
 * - 在震荡市场中效果最佳
 * - 强趋势中可能产生连续的假信号
 */
public class StochasticRsi {
    /**
     * period 计算周期
     *
     * 默认值：14
     * 用途：RSI和随机窗口的周期长度
     */
    public var period: Int64 = 14

    /**
     * RsiIndicator RSI指标实例
     *
     * 用于计算初始的RSI值序列
     */
    public let RsiIndicator: Rsi

    /**
     * MinIndicator 最小值指标实例
     *
     * 用于计算RSI序列的最小值
     */
    public let MinIndicator: MovingMin

    /**
     * MaxIndicator 最大值指标实例
     *
     * 用于计算RSI序列的最大值
     */
    public let MaxIndicator: MovingMax

    /**
     * 默认构造函数
     *
     * 使用默认周期14初始化Stochastic RSI指标
     */
    public StochasticRsi() {
        this.RsiIndicator = Rsi(this.period)
        this.MinIndicator = MovingMin(this.period)
        this.MaxIndicator = MovingMax(this.period)
    }

    /**
     * 带参数构造函数
     *
     * @param period 计算周期，必须大于0
     */
    public init(period: Int64) {
        this.period = period
        this.RsiIndicator = Rsi(period)
        this.MinIndicator = MovingMin(period)
        this.MaxIndicator = MovingMax(period)
    }

    /**
     * compute 计算随机RSI指标值
     *
     * 计算步骤：
     * 1. 计算原始价格序列的RSI值
     * 2. 在指定周期内找到RSI的最大值和最小值
     * 3. 应用随机公式：StochRSI = (RSI - MinRSI) / (MaxRSI - MinRSI)
     *
     * @param values 价格序列迭代器
     * @return Stochastic RSI值迭代器，范围在0-100之间
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let rsisSplice = duplicate(RsiIndicator.compute(values), 3)

        // Max/Min 需要满窗，先跳过对应 IdlePeriod。
        rsisSplice[0] = skip(rsisSplice[0], MaxIndicator.idlePeriod())

        let minRsisSplice = duplicate(MinIndicator.compute(rsisSplice[1]), 2)
        let maxRsis = MaxIndicator.compute(rsisSplice[2])

        let result = divide(
            subtract(rsisSplice[0], minRsisSplice[0]),
            subtract(maxRsis, minRsisSplice[1])
        )

        return result
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * 总空闲周期 = RSI的空闲周期 + 最小/最大值窗口的空闲周期
     *
     * @return 需要预热的周期数
     */
    public func idlePeriod(): Int64 {
        return RsiIndicator.idlePeriod() + MinIndicator.idlePeriod()
    }
}
