package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class UlcerIndex {
    public var Period: Int64

    public init() { this.Period = 14 }
    public init(period: Int64) { this.Period = period }

    public func Compute(closings: Iterator<Float64>): Iterator<Float64> {
        let cs = Duplicate(closings, 2)

        let movingMax = MovingMax(Period)
        let highs = Duplicate(movingMax.Compute(cs[0]), 2)

        cs[1] = Skip(cs[1], movingMax.IdlePeriod())

        let drawdown = MultiplyBy(
            Divide(
                Subtract(cs[1], highs[0]),
                highs[1]
            ),
            100.0
        )

        let sma = Sma()
        sma.Period = Period
        let squaredAvg = Pow(sma.Compute(drawdown), 2.0)

        return Sqrt(squaredAvg)
    }

    public func IdlePeriod(): Int64 { return (Period - 1) * 2 }
}

