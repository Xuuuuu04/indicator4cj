package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultEnvelopePercentage: Float64 = 20.0
public const DefaultEnvelopePeriod: Int64 = 20

// 价格包络线：上下轨为 MA*(1±pct)。
public class Envelope {
    // 移动平均指标
    public let maIndicator: Ma
    // 百分比
    public var percentage: Float64 = DefaultEnvelopePercentage

    public Envelope() {
        this.maIndicator = Sma(DefaultEnvelopePeriod)
        // percentage使用成员变量默认值
    }

    public init(ma: Ma, percentage: Float64) {
        this.maIndicator = ma
        this.percentage = percentage
    }

// compute 计算指标。
    public func compute(closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let middleSplice = duplicate(maIndicator.compute(closings), 3)

        let upper = multiplyBy(middleSplice[0], 1.0 + (percentage / 100.0))
        let lower = multiplyBy(middleSplice[2], 1.0 - (percentage / 100.0))

        return (upper, middleSplice[1], lower)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return maIndicator.idlePeriod() }

// toString 返回指标的字符串表示。
    public func toString(): String { return "Envelope(${percentage})" }
}
