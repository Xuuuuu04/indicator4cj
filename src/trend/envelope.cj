package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultEnvelopePercentage: Float64 = 20.0
public const DefaultEnvelopePeriod: Int64 = 20

// 价格包络线：上下轨为 MA*(1±pct)。
public class Envelope {
    public let MaIndicator: Ma
    public var Percentage: Float64 = DefaultEnvelopePercentage

    public Envelope() {
        this.MaIndicator = Sma(DefaultEnvelopePeriod)
        this.Percentage = Percentage
    }

    public init(ma: Ma, percentage: Float64) {
        this.MaIndicator = ma
        this.Percentage = percentage
    }

// compute 计算指标。
    public func compute(closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let middleSplice = Duplicate(MaIndicator.compute(closings), 3)

        let upper = MultiplyBy(middleSplice[0], 1.0 + (Percentage / 100.0))
        let lower = MultiplyBy(middleSplice[2], 1.0 - (Percentage / 100.0))

        return (upper, middleSplice[1], lower)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return MaIndicator.idlePeriod() }

// toString 返回指标的字符串表示。
    public func toString(): String { return "Envelope(${Percentage})" }
}
