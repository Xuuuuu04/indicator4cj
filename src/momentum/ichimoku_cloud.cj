package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * IchimokuCloud 一目均衡表指标
 *
 * 包含五条线：
 * - 转换线 (Tenkan-sen)：短期平衡点，(Max(High,9) + Min(Low,9)) / 2
 * - 基准线 (Kijun-sen)：中期平衡点，(Max(High,26) + Min(Low,26)) / 2
 * - 先行带A (Senkou Span A)：(转换线 + 基准线) / 2，向前平移26期
 * - 先行带B (Senkou Span B)：(Max(High,52) + Min(Low,52)) / 2，向前平移26期
 * - 迟行线 (Chikou Span)：当前收盘价向后平移26期
 *
 * 详细说明：
 * 日本技术分析师发明，提供全面的市场视图，包括趋势、支撑/阻力、动量等信息。
 * 先行带A和B之间的区域称为"云带"，是关键的支撑/阻力区域。
 *
 * 特点：
 * - 多维度分析：同时显示趋势、动量、支撑/阻力
 * - 领先指标：云带提前26期显示未来的支撑/阻力
 * - 视觉直观：一目了然地判断市场状态
 *
 * 交易信号：
 * - 转换线交叉：转换线上穿基准线为买入信号
 * - 价格突破云带：价格从下方突破云带为强势买入
 * - 云带厚度：云带越厚，支撑/阻力越强
 * - 迟行线确认：迟行线突破价格为趋势确认
 *
 * 创建者：Goichi Hosada（细田悟一）
 * 创建时间：1960年代
 *
 * 注意事项：
 * - 参数可以根据不同市场调整
 * - 最适合趋势明显的市场
 * - 云带区域内的价格波动视为震荡
 */
public class IchimokuCloud {
    /**
     * conversionPeriod 转换线周期（短期）
     *
     * 默认值：9
     * 用途：计算转换线的时间窗口
     */
    public var conversionPeriod: Int64 = 9

    /**
     * basePeriod 基准线周期（中期）
     *
     * 默认值：26
     * 用途：计算基准线的时间窗口
     */
    public var basePeriod: Int64 = 26

    /**
     * leadingPeriod 领先线周期（长期）
     *
     * 默认值：52
     * 用途：计算先行带B的时间窗口
     */
    public var leadingPeriod: Int64 = 52

    /**
     * laggingShift 迟行线平移周期
     *
     * 默认值：26
     * 用途：迟行线和先行带向前平移的周期数
     */
    public var laggingShift: Int64 = 26

    /**
     * compute 计算一目均衡表指标
     *
     * @param highs 最高价迭代器
     * @param lows 最低价迭代器
     * @param closes 收盘价迭代器
     * @return 五元组，依次为：
     *         - 转换线 (Tenkan-sen)
     *         - 基准线 (Kijun-sen)
     *         - 先行带A (Senkou Span A)
     *         - 先行带B (Senkou Span B)
     *         - 迟行线 (Chikou Span)
     */
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let highsSp = duplicate(highs, 3)
        let lowsSp = duplicate(lows, 3)

        let convMax = MovingMax(conversionPeriod)
        let convMin = MovingMin(conversionPeriod)
        let baseMax = MovingMax(basePeriod)
        let baseMin = MovingMin(basePeriod)
        let leadMax = MovingMax(leadingPeriod)
        let leadMin = MovingMin(leadingPeriod)

        // 转换线
        let conv = duplicate(
            divideBy(
            add(convMax.compute(highsSp[0]), convMin.compute(lowsSp[0])),
            2.0
            ),
            2
        )

        // 基准线
        let base = duplicate(
            divideBy(
            add(baseMax.compute(highsSp[1]), baseMin.compute(lowsSp[1])),
            2.0
            ),
            2
        )

        // 对齐 Tenkan 与 Kijun 的 idle 差
        let diffConvBase = baseMax.idlePeriod() - convMax.idlePeriod()
        conv[0] = skip(conv[0], diffConvBase)
        conv[1] = skip(conv[1], diffConvBase)

        // 先行带A
        var senkouA = divideBy(add(conv[0], base[0]), 2.0)

        // 先行带B
        let senkouB_raw = divideBy(
            add(leadMax.compute(highsSp[2]), leadMin.compute(lowsSp[2])),
            2.0
        )

        // 领先线对齐到最长窗口
        let diffLeadBase = leadMax.idlePeriod() - baseMax.idlePeriod()
        senkouA = skip(senkouA, diffLeadBase)
        conv[1] = skip(conv[1], diffLeadBase)
        base[1] = skip(base[1], diffLeadBase)

        let senkouB = senkouB_raw

        // Chikou：向左移 laggingShift，相当于向右平移 lagging 并裁掉领先 idle。
        let chikouShifted = shift(closes, laggingShift, 0.0)
        let chikou = skip(chikouShifted, leadMax.idlePeriod())

        return (conv[1], base[1], senkouA, senkouB, chikou)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（leadingPeriod-1），默认为51个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return leadingPeriod - 1 }
}

