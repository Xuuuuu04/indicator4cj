package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class BollingerBands {
    public var Period: Int64

    public init() { this.Period = 20 }
    public init(period: Int64) { this.Period = period }

    public func compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let cs = Duplicate(c, 2)
        let sma = Sma()
        sma.Period = Period
        let std = MovingStd()
        std.Period = Period

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

    public func idlePeriod(): Int64 { return Period - 1 }
}

