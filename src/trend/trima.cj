package indicator4cj.trend

import std.core.*

/**
 * DefaultTrimaPeriod TRIMA默认周期
 *
 * 默认值：15
 * 用途：三角移动平均的计算周期
 */
public const DefaultTrimaPeriod: Int64 = 15

/**
 * Trima 三角移动平均线
 *
 * 计算公式：TRIMA = SMA(SMA(price, ceil(n/2)), floor(n/2))
 *
 * 详细说明：
 * 对SMA再次进行平均，权重呈三角形分布，中间数据权重最大。
 * 通过双重平滑减少噪音，同时保持较好的趋势跟踪能力。
 *
 * 特点：
 * - 三角权重：中间时期数据权重最大，两端权重递减
 * - 双重平滑：对价格数据进行两次平均，进一步平滑曲线
 * - 滞后适中：介于SMA和EMA之间
 * - 噪音过滤：比单次SMA更好地过滤价格噪音
 *
 * 权重分布：
 * - 周期为奇数：权重对称，中间值权重最大
 * - 周期为偶数：两个中间值权重最大且相等
 *
 * 用途：
 * - 趋势识别：过滤短期波动，显示主要趋势
 * - 支撑阻力：作为动态支撑和阻力位
 * - 信号过滤：配合其他指标生成交易信号
 *
 * 交易信号：
 * - 价格上穿TRIMA：可能的买入信号
 * - 价格下穿TRIMA：可能的卖出信号
 *
 * 注意事项：
 * - 滞后性比SMA稍大
 * - 适合中长线交易
 * - 在震荡市场中表现良好
 */
public class Trima {
    /**
     * period 三角移动平均周期
     *
     * 默认值：DefaultTrimaPeriod（15）
     * 用途：确定TRIMA的窗口大小
     */
    public var period: Int64 = DefaultTrimaPeriod

    /**
     * 默认构造函数
     *
     * 使用默认周期初始化TRIMA
     */
    public Trima() {
        // 使用默认值
    }

    /**
     * 带参数构造函数
     *
     * @param period 三角移动平均周期
     */
    public init(period: Int64) {
        this.period = period
    }

    /**
     * compute 计算三角移动平均线
     *
     * 计算方法：
     * 1. 将周期分为两个子周期 p1 和 p2
     * 2. 计算第一层SMA：SMA(price, p2)
     * 3. 计算第二层SMA：SMA(SMA1, p1)
     *
     * @param values 价格数据迭代器
     * @return TRIMA值迭代器
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let (p1, p2) = calculatePeriods()
        let sma1 = Sma(p1)
        let sma2 = Sma(p2)
        return sma1.compute(sma2.compute(values))
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（p1 + p2 - 2）
     */
    public func idlePeriod(): Int64 {
        let (p1, p2) = calculatePeriods()
        return p1 + p2 - 2
    }

    /**
     * calculatePeriods 计算三角移动平均的子周期
     *
     * 根据主周期的奇偶性分配两个子周期：
     * - 周期为偶数：p1 = n/2, p2 = p1+1
     * - 周期为奇数：p1 = p2 = (n+1)/2
     *
     * @return 元组 (p1, p2)，分别对应第二层和第一层SMA的周期
     */
    private func calculatePeriods(): (Int64, Int64) {
        var p1: Int64
        var p2: Int64
        if (period % 2 == 0) {
            p1 = period / 2
            p2 = p1 + 1
        } else {
            p1 = (period + 1) / 2
            p2 = p1
        }
        return (p1, p2)
    }

    /**
     * toString 返回指标的字符串表示
     *
     * @return 格式为 "TRIMA(period)" 的字符串
     */
    public func toString(): String { return "TRIMA(${period})" }
}
