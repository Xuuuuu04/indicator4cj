package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTsiFirstSmoothingPeriod: Int64 = 25
public const DefaultTsiSecondSmoothingPeriod: Int64 = 13

// True Strength Index (TSI)
public class Tsi {
    public let FirstSmoothing: Ma
    public let SecondSmoothing: Ma
    private let _firstPeriod: Int64
    private let _secondPeriod: Int64

    public init() {
        this._firstPeriod = DefaultTsiFirstSmoothingPeriod
        this._secondPeriod = DefaultTsiSecondSmoothingPeriod
        this.FirstSmoothing = Ema(_firstPeriod)
        this.SecondSmoothing = Ema(_secondPeriod)
    }

    public init(firstSmoothingPeriod: Int64, secondSmoothingPeriod: Int64) {
        this._firstPeriod = firstSmoothingPeriod
        this._secondPeriod = secondSmoothingPeriod
        this.FirstSmoothing = Ema(_firstPeriod)
        this.SecondSmoothing = Ema(_secondPeriod)
    }

    public func Compute(closings: Iterator<Float64>): Iterator<Float64> {
        let pcs = Duplicate(Change(closings, 1), 2)

        let pcds = FirstSmoothing.Compute(SecondSmoothing.Compute(pcs[0]))
        let apcds = FirstSmoothing.Compute(SecondSmoothing.Compute(Abs(pcs[1])))

        let tsi = MultiplyBy(Divide(pcds, apcds), 100.0)
        return tsi
    }

    public func IdlePeriod(): Int64 {
        return FirstSmoothing.IdlePeriod() + SecondSmoothing.IdlePeriod() + 1
    }

    public func toString(): String {
        return "TSI(${_firstPeriod},${_secondPeriod})"
    }
}

public func NewTsi(): Tsi { return Tsi() }
public func NewTsiWith(firstSmoothingPeriod: Int64, secondSmoothingPeriod: Int64): Tsi {
    return Tsi(firstSmoothingPeriod, secondSmoothingPeriod)
}


