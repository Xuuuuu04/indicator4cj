package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultKdjMinMaxPeriod: Int64 = 9
public const DefaultKdjSma1Period: Int64 = 3
public const DefaultKdjSma2Period: Int64 = 3

// KDJ 指标：返回 K、D、J。
public class Kdj {
    public let MovingMaxInd: MovingMax
    public let MovingMinInd: MovingMin
    public let Sma1: Sma
    public let Sma2: Sma

    public init() {
        this.MovingMaxInd = MovingMax(DefaultKdjMinMaxPeriod)
        this.MovingMinInd = MovingMin(DefaultKdjMinMaxPeriod)
        this.Sma1 = Sma(DefaultKdjSma1Period)
        this.Sma2 = Sma(DefaultKdjSma2Period)
    }

    public func Compute(high: Iterator<Float64>, low: Iterator<Float64>, closing: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let highest = MovingMaxInd.Compute(high)
        let lowests = Duplicate(MovingMinInd.Compute(low), 2)

        let closingShift = Skip(closing, MovingMaxInd.Period - 1)

        let rsv = MultiplyBy(
            Divide(
                Subtract(closingShift, lowests[0]),
                Subtract(highest, lowests[1])
            ),
            100.0
        )

        let ks = Duplicate(Sma1.Compute(rsv), 3)
        let ds = Duplicate(Sma2.Compute(ks[0]), 2)

        ks[1] = Skip(ks[1], Sma2.Period - 1)
        ks[2] = Skip(ks[2], Sma2.Period - 1)

        let j = Subtract(MultiplyBy(ks[1], 3.0), MultiplyBy(ds[0], 2.0))

        return (ks[2], ds[1], j)
    }

    public func IdlePeriod(): Int64 {
        return MovingMaxInd.Period + Sma1.Period + Sma2.Period - 3
    }
}

public func NewKdj(): Kdj { return Kdj() }


