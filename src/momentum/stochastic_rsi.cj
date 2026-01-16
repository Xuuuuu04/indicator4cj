package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Stochastic RSI：对 RSI 序列再应用随机振荡计算，与 Go 版保持一致。
public class StochasticRsi {
    // 周期
    public var period: Int64 = 14
    // RSI指标
    public let RsiIndicator: Rsi
    // 最小值指标
    public let MinIndicator: MovingMin
    // 最大值指标
    public let MaxIndicator: MovingMax

    public StochasticRsi() {
        this.RsiIndicator = Rsi(this.period)
        this.MinIndicator = MovingMin(this.period)
        this.MaxIndicator = MovingMax(this.period)
    }

    public init(period: Int64) {
        this.period = period
        this.RsiIndicator = Rsi(period)
        this.MinIndicator = MovingMin(period)
        this.MaxIndicator = MovingMax(period)
    }

    // 计算公式同 Go：
    // (RSI - Min(RSI)) / (Max(RSI) - Min(RSI))
    // compute 计算随机相对强弱指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let rsisSplice = duplicate(RsiIndicator.compute(values), 3)

        // Max/Min 需要满窗，先跳过对应 IdlePeriod。
        rsisSplice[0] = skip(rsisSplice[0], MaxIndicator.idlePeriod())

        let minRsisSplice = duplicate(MinIndicator.compute(rsisSplice[1]), 2)
        let maxRsis = MaxIndicator.compute(rsisSplice[2])

        let result = divide(
            subtract(rsisSplice[0], minRsisSplice[0]),
            subtract(maxRsis, minRsisSplice[1])
        )

        return result
    }

    // idlePeriod返回RSI的空闲周期加最小最大值的空闲周期
    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return RsiIndicator.idlePeriod() + MinIndicator.idlePeriod()
    }
}
