package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * AwesomeOscillator 绝妙振荡器指标
 *
 * 计算公式：AO = SMA(MedianPrice, 5) - SMA(MedianPrice, 34)
 * 其中 MedianPrice = (High + Low) / 2
 *
 * 详细说明：
 * 该指标用于衡量市场动量，由 Bill Williams 创建。
 * 通过比较短期（5周期）和中期（34周期）的中间价移动平均线差异，
 * 来判断市场的动量方向和强度。
 *
 * 特点：
 * - 零轴上下波动：正值表示看涨动量，负值表示看跌动量
 * - 柱状图显示：通常以红绿柱状图展示，直观显示动量变化
 * - 领先指标：相比价格走势，能提前发现动量衰减
 *
 * 交易信号：
 * - 零轴交叉：从负变正为买入信号，从正变负为卖出信号
 * - 趋势确认：持续同向表示趋势强劲
 * - 背离信号：价格创新高但AO未创新高，可能预示反转
 *
 * 创建者：Bill Williams（比尔·威廉姆斯）
 * 相关指标：属于 Bill Williams 交易体系的一部分
 */
public class AwesomeOscillator {
    /**
     * compute 计算绝妙振荡器指标值
     *
     * @param highs 最高价迭代器
     * @param lows 最低价迭代器
     * @return 振荡器值迭代器，正值表示看涨动量，负值表示看跌动量
     */
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>): Iterator<Float64> {
        let medianDup = duplicate(
            divideBy(
                add(highs, lows),
                2.0
            ),
            2
        )
        let s5 = Sma()
        s5.period = 5
        let s34 = Sma()
        s34.period = 34
        var fast = s5.compute(medianDup[0])
        var slow = s34.compute(medianDup[1])
        // 对齐：跳过 fast 前 (34-5)=29 个值，使两条均从 index 33 开始。
        fast = skip(fast, 29)
        return subtract(fast, slow)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（34-1=33），前33个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return 34 - 1 }
}

