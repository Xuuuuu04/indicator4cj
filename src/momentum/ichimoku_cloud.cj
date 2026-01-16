package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Ichimoku Cloud，对齐逻辑与 Go 版一致：先对齐窗口 idle，再生成领先/滞后线。
public class IchimokuCloud {
    // 转换周期
    public var conversionPeriod: Int64 = 9
    // 基准周期
    public var basePeriod: Int64 = 26
    // 领先周期
    public var leadingPeriod: Int64 = 52
    // 滞后平移
    public var laggingShift: Int64 = 26

    // compute 计算一目均衡表指标。
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

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return leadingPeriod - 1 }
}

