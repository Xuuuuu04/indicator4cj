package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * ChaikinOscillator 佳庆振荡器
 *
 * 计算公式：CO = EMA(AD, 3) - EMA(AD, 10)
 * 其中 AD（累积/派发线）= ((Close - Low) - (High - Close)) / (High - Low) * Volume
 *
 * 详细说明：
 * 该指标结合了价格和成交量信息，用于衡量资金流向。
 * 通过计算累积/派发线（AD）的短期和长期EMA差异，判断买卖压力。
 *
 * 特点：
 * - 量价结合：同时考虑价格位置和成交量
 * - 资金流向：正值表示资金流入，负值表示资金流出
 * - 领先指标：能提前发现趋势反转
 *
 * 交易信号：
 * - 零轴交叉：从负变正为买入信号，从正变负为卖出信号
 * - 背离信号：价格创新高但CO未创新高，可能预示反转
 * - 趋势确认：持续同向表示趋势强劲
 *
 * 创建者：Marc Chaikin（马克·蔡金）
 * 相关指标：与 Chaikin Money Flow 类似，但计算方法不同
 *
 * 注意事项：
 * - 在横盘市场中可能产生较多假信号
 * - 适合配合其他趋势指标使用
 */
public class ChaikinOscillator {
    /**
     * compute 计算蔡金振荡器指标值
     *
     * @param highs 最高价迭代器
     * @param lows 最低价迭代器
     * @param closes 收盘价迭代器
     * @param volumes 成交量迭代器
     * @return 振荡器值迭代器，正值表示资金流入，负值表示资金流出
     */
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        // AD = ((收盘价 - 最低价) - (最高价 - 收盘价)) / (最高价 - 最低价) * 成交量
        let hl = subtract(highs, lows)
        let mfm = divide(
            subtract(
                subtract(closes, lows),
                subtract(highs, closes)
            ),
            hl
        )
        let ad = multiply(mfm, volumes)

        let e3 = Ema(3)
        let e10 = Ema(10)
        return subtract(e3.compute(ad), e10.compute(ad))
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（10-1=9），前9个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return 10 - 1 }
}

