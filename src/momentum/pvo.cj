package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// PVO = 100 * (EMA_快速周期(成交量) - EMA_慢速周期(成交量)) / EMA_慢速周期(成交量)
public class Pvo {
    // 快速周期
    public var fastPeriod: Int64 = 12
    // 慢速周期
    public var slowPeriod: Int64 = 26

    public Pvo() {
        this.fastPeriod = fastPeriod
        this.slowPeriod = slowPeriod
    }

    public init(fast: Int64, slow: Int64) {
        this.fastPeriod = fast
        this.slowPeriod = slow
    }

    // compute 计算成交量振荡器指标。
    public func compute(volumes: Iterator<Float64>): Iterator<Float64> {
        let fastEma = Ema(fastPeriod).compute(volumes)
        let slowEma = Ema(slowPeriod).compute(volumes)
        let diff = subtract(fastEma, slowEma)
        return multiplyBy(divide(diff, slowEma), 100.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return slowPeriod - 1 }
}

