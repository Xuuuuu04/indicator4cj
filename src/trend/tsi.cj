package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTsiFirstSmoothingPeriod: Int64 = 25
public const DefaultTsiSecondSmoothingPeriod: Int64 = 13

// True Strength Index (TSI)
public class Tsi {
    public let FirstSmoothing: Ma
    public let SecondSmoothing: Ma
    private let firstPeriod: Int64
    private let secondPeriod: Int64

    public Tsi() {
        this.firstPeriod = DefaultTsiFirstSmoothingPeriod
        this.secondPeriod = DefaultTsiSecondSmoothingPeriod
        this.FirstSmoothing = Ema(firstPeriod)
        this.SecondSmoothing = Ema(secondPeriod)
    }

    public init(firstSmoothingPeriod: Int64, secondSmoothingPeriod: Int64) {
        this.firstPeriod = firstSmoothingPeriod
        this.secondPeriod = secondSmoothingPeriod
        this.FirstSmoothing = Ema(firstPeriod)
        this.SecondSmoothing = Ema(secondPeriod)
    }

// compute 计算真实强度指标。
    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let pcs = Duplicate(Change(closings, 1), 2)

        let pcds = FirstSmoothing.compute(SecondSmoothing.compute(pcs[0]))
        let apcds = FirstSmoothing.compute(SecondSmoothing.compute(Abs(pcs[1])))

        let tsi = MultiplyBy(Divide(pcds, apcds), 100.0)
        return tsi
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return FirstSmoothing.idlePeriod() + SecondSmoothing.idlePeriod() + 1
    }

// toString 返回指标的字符串表示。
    public func toString(): String {
        return "TSI(${firstPeriod},${secondPeriod})"
    }
}
