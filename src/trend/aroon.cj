package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultAroonPeriod: Int64 = 25

// Aroon 上升/下降指标。
public class Aroon {
    // 周期
    public var period: Int64 = DefaultAroonPeriod

    public Aroon() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

// compute 计算指标。
    public func compute(high: Iterator<Float64>, low: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let movingMax = MovingMax(period)
        let movingMin = MovingMin(period)

        let sinceLastHigh = MaxSince(movingMax.compute(high), period)
        let sinceLastLow = MinSince(movingMin.compute(low), period)

        var aroonUp = MultiplyBy(IncrementBy(MultiplyBy(sinceLastHigh, -1.0), Float64(period)), 100.0 / Float64(period))
        aroonUp = RoundDigits(aroonUp, 0)

        var aroonDown = MultiplyBy(IncrementBy(MultiplyBy(sinceLastLow, -1.0), Float64(period)), 100.0 / Float64(period))
        aroonDown = RoundDigits(aroonDown, 0)

        return (aroonUp, aroonDown)
    }
}
