package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class BollingerBands {
    // 周期
    public var period: Int64 = 20

    public BollingerBands() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算布林带指标。
    public func compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let cs = duplicate(c, 2)
        let sma = Sma()
        sma.period = period
        let std = MovingStd()
        std.period = period

        let middleBands = duplicate(
            sma.compute(cs[0]),
            3
        )

        let std2s = duplicate(
            multiplyBy(std.compute(cs[1]), 2.0),
            2
        )

        let upperBand = add(middleBands[0], std2s[0])
        let lowerBand = subtract(middleBands[1], std2s[1])

        return (upperBand, middleBands[2], lowerBand)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

