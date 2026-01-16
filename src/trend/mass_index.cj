package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultMassIndexPeriod1: Int64 = 9
public const DefaultMassIndexPeriod2: Int64 = 9
public const DefaultMassIndexPeriod3: Int64 = 25

// 质量指数
public class MassIndex {
    // 快速EMA
    public let ema1: Ema
    // 慢速EMA
    public let ema2: Ema
    // 移动求和
    public let movingSumInd: MovingSum

    public MassIndex() {
        this.ema1 = Ema(DefaultMassIndexPeriod1)
        this.ema2 = Ema(DefaultMassIndexPeriod2)
        this.movingSumInd = MovingSum(DefaultMassIndexPeriod3)
    }

    // compute 计算质量指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Duplicate(
            this.ema1.compute(
                Subtract(highs, lows)
            ),
            2
        )

        let ema2 = this.ema2.compute(ema1[0])
        ema1[1] = Skip(ema1[1], this.ema2.period - 1)

        let ratio = Divide(ema1[1], ema2)
        let mi = this.movingSumInd.compute(ratio)
        return mi
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period + this.movingSumInd.period - 3
    }
}

