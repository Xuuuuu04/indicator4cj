package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultMassIndexPeriod1: Int64 = 9
public const DefaultMassIndexPeriod2: Int64 = 9
public const DefaultMassIndexPeriod3: Int64 = 25

// Mass Index
public class MassIndex {
    public let Ema1: Ema
    public let Ema2: Ema
    public let MovingSumInd: MovingSum

    public init() {
        this.Ema1 = Ema(DefaultMassIndexPeriod1)
        this.Ema2 = Ema(DefaultMassIndexPeriod2)
        this.MovingSumInd = MovingSum(DefaultMassIndexPeriod3)
    }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Duplicate(
            Ema1.compute(
                Subtract(highs, lows)
            ),
            2
        )

        let ema2 = Ema2.compute(ema1[0])
        ema1[1] = Skip(ema1[1], Ema2.Period - 1)

        let ratio = Divide(ema1[1], ema2)
        let mi = MovingSumInd.compute(ratio)
        return mi
    }

    public func idlePeriod(): Int64 {
        return Ema1.Period + Ema2.Period + MovingSumInd.Period - 3
    }
}

