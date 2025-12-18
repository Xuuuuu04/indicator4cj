package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class ChandelierExit {
    public var Period: Int64
    public var Multiplier: Float64

    public init() {
        this.Period = 22
        this.Multiplier = 3.0
    }

    public init(period: Int64, multiplier: Float64) {
        this.Period = period
        this.Multiplier = multiplier
    }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)

        let movingMax = MovingMax(Period)
        let movingMin = MovingMin(Period)
        let atr = Atr(Period)

        let skipMax = atr.IdlePeriod() - movingMax.IdlePeriod()
        let skipMin = atr.IdlePeriod() - movingMin.IdlePeriod()

        let maxHighs = Skip(movingMax.Compute(hs[0]), skipMax)
        let minLows = Skip(movingMin.Compute(ls[0]), skipMin)

        let atrScaled = Duplicate(
            MultiplyBy(
                atr.Compute(hs[1], ls[1], closings),
                Multiplier
            ),
            2
        )

        let ceLong = Subtract(maxHighs, atrScaled[0])
        let ceShort = Add(minLows, atrScaled[1])

        return (ceLong, ceShort)
    }

    public func IdlePeriod(): Int64 { return Period }
}

