package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultEnvelopePercentage: Float64 = 20.0
public const DefaultEnvelopePeriod: Int64 = 20

// 价格包络线：上下轨为 MA*(1±pct)。
public class Envelope {
    public let MaIndicator: Ma
    public var Percentage: Float64

    public init() {
        this.MaIndicator = Sma(DefaultEnvelopePeriod)
        this.Percentage = DefaultEnvelopePercentage
    }

    public init(ma: Ma, percentage: Float64) {
        this.MaIndicator = ma
        this.Percentage = percentage
    }

    public func Compute(closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let middleSplice = Duplicate(MaIndicator.Compute(closings), 3)

        let upper = MultiplyBy(middleSplice[0], 1.0 + (Percentage / 100.0))
        let lower = MultiplyBy(middleSplice[2], 1.0 - (Percentage / 100.0))

        return (upper, middleSplice[1], lower)
    }

    public func IdlePeriod(): Int64 { return MaIndicator.IdlePeriod() }

    public func toString(): String { return "Envelope(${Percentage})" }
}

public func NewEnvelope(): Envelope {
    return Envelope()
}

public func NewEnvelopeWithSma(): Envelope {
    return Envelope(Sma(DefaultEnvelopePeriod), DefaultEnvelopePercentage)
}

public func NewEnvelopeWithEma(): Envelope {
    return Envelope(Ema(DefaultEnvelopePeriod), DefaultEnvelopePercentage)
}


