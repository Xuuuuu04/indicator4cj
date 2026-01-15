package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultAroonPeriod: Int64 = 25

// Aroon Up/Down 指标。
public class Aroon {
    public var period: Int64 = DefaultAroonPeriod

    public Aroon() { this.period = period }
    public init(period: Int64) { this.period = period }

    public func compute(high: Iterator<Float64>, low: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let movingMax = MovingMax(this.period)
        let movingMin = MovingMin(this.period)

        let sinceLastHigh = MaxSince(movingMax.compute(high), this.period)
        let sinceLastLow = MinSince(movingMin.compute(low), this.period)

        var aroonUp = MultiplyBy(IncrementBy(MultiplyBy(sinceLastHigh, -1.0), Float64(this.period)), 100.0 / Float64(this.period))
        aroonUp = RoundDigits(aroonUp, 0)

        var aroonDown = MultiplyBy(IncrementBy(MultiplyBy(sinceLastLow, -1.0), Float64(this.period)), 100.0 / Float64(this.period))
        aroonDown = RoundDigits(aroonDown, 0)

        return (aroonUp, aroonDown)
    }
}

