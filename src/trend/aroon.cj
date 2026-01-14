package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultAroonPeriod: Int64 = 25

// Aroon Up/Down 指标。
public class Aroon {
    public var Period: Int64

    public init() { this.Period = DefaultAroonPeriod }
    public init(period: Int64) { this.Period = period }

    public func compute(high: Iterator<Float64>, low: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let movingMax = MovingMax(Period)
        let movingMin = MovingMin(Period)

        let sinceLastHigh = MaxSince(movingMax.compute(high), Period)
        let sinceLastLow = MinSince(movingMin.compute(low), Period)

        var aroonUp = MultiplyBy(IncrementBy(MultiplyBy(sinceLastHigh, -1.0), Float64(Period)), 100.0 / Float64(Period))
        aroonUp = RoundDigits(aroonUp, 0)

        var aroonDown = MultiplyBy(IncrementBy(MultiplyBy(sinceLastLow, -1.0), Float64(Period)), 100.0 / Float64(Period))
        aroonDown = RoundDigits(aroonDown, 0)

        return (aroonUp, aroonDown)
    }
}

