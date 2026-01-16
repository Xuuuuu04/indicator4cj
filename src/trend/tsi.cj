package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTsiFirstSmoothingPeriod: Int64 = 25
public const DefaultTsiSecondSmoothingPeriod: Int64 = 13

// 真实强度指数（TSI）
public class Tsi {
    // 初次平滑
    public let firstSmoothing: Ma
    // 二次平滑
    public let secondSmoothing: Ma
    private let _firstPeriod: Int64
    private let _secondPeriod: Int64

    public Tsi() {
        this._firstPeriod = DefaultTsiFirstSmoothingPeriod
        this._secondPeriod = DefaultTsiSecondSmoothingPeriod
        this.firstSmoothing = Ema(_firstPeriod)
        this.secondSmoothing = Ema(_secondPeriod)
    }

    public init(firstSmoothingPeriod: Int64, secondSmoothingPeriod: Int64) {
        this._firstPeriod = firstSmoothingPeriod
        this._secondPeriod = secondSmoothingPeriod
        this.firstSmoothing = Ema(_firstPeriod)
        this.secondSmoothing = Ema(_secondPeriod)
    }

// compute 计算真实强度指标。
    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let pcs = duplicate(change(closings, 1), 2)

        let pcds = firstSmoothing.compute(secondSmoothing.compute(pcs[0]))
        let apcds = firstSmoothing.compute(secondSmoothing.compute(abs(pcs[1])))

        let tsi = multiplyBy(divide(pcds, apcds), 100.0)
        return tsi
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return firstSmoothing.idlePeriod() + secondSmoothing.idlePeriod() + 1
    }

// toString 返回指标的字符串表示。
    public func toString(): String {
        return "TSI(${_firstPeriod},${_secondPeriod})"
    }
}
