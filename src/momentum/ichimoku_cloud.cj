package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Ichimoku Cloud，对齐逻辑与 Go 版一致：先对齐窗口 idle，再生成领先/滞后线。
public class IchimokuCloud {
    // 转换周期
    public var ConversionPeriod: Int64 = 9
    // 基准周期
    public var BasePeriod: Int64 = 26
    // 领先周期
    public var LeadingPeriod: Int64 = 52
    // 滞后平移
    public var LaggingShift: Int64 = 26

    // compute 计算一目均衡表指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let highsSp = Duplicate(highs, 3)
        let lowsSp = Duplicate(lows, 3)

        let convMax = MovingMax(ConversionPeriod)
        let convMin = MovingMin(ConversionPeriod)
        let baseMax = MovingMax(BasePeriod)
        let baseMin = MovingMin(BasePeriod)
        let leadMax = MovingMax(LeadingPeriod)
        let leadMin = MovingMin(LeadingPeriod)

        // Tenkan
        let conv = Duplicate(
            DivideBy(
            Add(convMax.compute(highsSp[0]), convMin.compute(lowsSp[0])),
            2.0
            ),
            2
        )

        // Kijun
        let base = Duplicate(
            DivideBy(
            Add(baseMax.compute(highsSp[1]), baseMin.compute(lowsSp[1])),
            2.0
            ),
            2
        )

        // 对齐 Tenkan 与 Kijun 的 idle 差
        let diffConvBase = baseMax.idlePeriod() - convMax.idlePeriod()
        conv[0] = Skip(conv[0], diffConvBase)
        conv[1] = Skip(conv[1], diffConvBase)

        // Senkou A
        var senkouA = DivideBy(Add(conv[0], base[0]), 2.0)

        // Senkou B
        let senkouB_raw = DivideBy(
            Add(leadMax.compute(highsSp[2]), leadMin.compute(lowsSp[2])),
            2.0
        )

        // 领先线对齐到最长窗口
        let diffLeadBase = leadMax.idlePeriod() - baseMax.idlePeriod()
        senkouA = Skip(senkouA, diffLeadBase)
        conv[1] = Skip(conv[1], diffLeadBase)
        base[1] = Skip(base[1], diffLeadBase)

        let senkouB = senkouB_raw

        // Chikou：向左移 LaggingShift，相当于向右平移 lagging 并裁掉领先 idle。
        let chikouShifted = Shift(closes, LaggingShift, 0.0)
        let chikou = Skip(chikouShifted, leadMax.idlePeriod())

        return (conv[1], base[1], senkouA, senkouB, chikou)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return LeadingPeriod - 1 }
}

