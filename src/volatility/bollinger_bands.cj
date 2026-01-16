package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class BollingerBands {
    public var period: Int64 = 20

    public BollingerBands() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算布林带指标。
    public func compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let cs = Duplicate(c, 2)
        let sma = Sma()
        sma.period = this.period
        let std = MovingStd()
        std.period = this.period

        let middleBands = Duplicate(
            sma.compute(cs[0]),
            3
        )

        let std2s = Duplicate(
            MultiplyBy(std.compute(cs[1]), 2.0),
            2
        )

        let upperBand = Add(middleBands[0], std2s[0])
        let lowerBand = Subtract(middleBands[1], std2s[1])

        return (upperBand, middleBands[2], lowerBand)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}

