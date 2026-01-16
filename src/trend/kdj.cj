package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultKdjMinMaxPeriod: Int64 = 9
public const DefaultKdjSma1Period: Int64 = 3
public const DefaultKdjSma2Period: Int64 = 3

// KDJ 指标：返回 K、D、J。
public class Kdj {
    // 最高价移动
    public let MovingMaxInd: MovingMax
    // 最低价移动
    public let MovingMinInd: MovingMin
    // K值平滑
    public let Sma1: Sma
    // D值平滑
    public let Sma2: Sma

    public Kdj() {
        this.MovingMaxInd = MovingMax(DefaultKdjMinMaxPeriod)
        this.MovingMinInd = MovingMin(DefaultKdjMinMaxPeriod)
        this.Sma1 = Sma(DefaultKdjSma1Period)
        this.Sma2 = Sma(DefaultKdjSma2Period)
    }

    // compute 计算KDJ指标。
    public func compute(high: Iterator<Float64>, low: Iterator<Float64>, closing: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let highest = MovingMaxInd.compute(high)
        let lowests = duplicate(MovingMinInd.compute(low), 2)

        let closingShift = skip(closing, MovingMaxInd.period - 1)

        let rsv = multiplyBy(
            divide(
                subtract(closingShift, lowests[0]),
                subtract(highest, lowests[1])
            ),
            100.0
        )

        let ks = duplicate(Sma1.compute(rsv), 3)
        let ds = duplicate(Sma2.compute(ks[0]), 2)

        ks[1] = skip(ks[1], Sma2.period - 1)
        ks[2] = skip(ks[2], Sma2.period - 1)

        let j = subtract(multiplyBy(ks[1], 3.0), multiplyBy(ds[0], 2.0))

        return (ks[2], ds[1], j)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return MovingMaxInd.period + Sma1.period + Sma2.period - 3
    }
}

