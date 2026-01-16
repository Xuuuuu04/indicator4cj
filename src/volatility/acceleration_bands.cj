package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class AccelerationBands {
    public var period: Int64 = 20

    public AccelerationBands() { this.period = period }
    public init(period: Int64) { this.period = period }

    // compute 计算加速度带指标。
    public func compute(high: Iterator<Float64>, low: Iterator<Float64>, closing: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let highs = Duplicate(high, 3)
        let lows = Duplicate(low, 3)

        let ks = Duplicate(
            Divide(
                Subtract(highs[0], lows[0]),
                Add(highs[1], lows[1])
            ),
            2
        )

        let sma = Sma()
        sma.period = this.period

        let upper = sma.compute(
            Multiply(
                highs[2],
                IncrementBy(
                    MultiplyBy(ks[0], 4.0),
                    1.0
                )
            )
        )

        let middle = sma.compute(closing)

        let lower = sma.compute(
            Multiply(
                lows[2],
                IncrementBy(
                    MultiplyBy(ks[1], -4.0),
                    1.0
                )
            )
        )

        return (upper, middle, lower)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}

