package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Stochastic RSI：对 RSI 序列再应用随机振荡计算，与 Go 版保持一致。
public class StochasticRsi {
    public var period: Int64
    public let RsiIndicator: Rsi
    public let MinIndicator: MovingMin
    public let MaxIndicator: MovingMax

    public init() {
        this.period = 14
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
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let rsisSplice = Duplicate(RsiIndicator.compute(values), 3)

        // Max/Min 需要满窗，先跳过对应 IdlePeriod。
        rsisSplice[0] = Skip(rsisSplice[0], MaxIndicator.idlePeriod())

        let minRsisSplice = Duplicate(MinIndicator.compute(rsisSplice[1]), 2)
        let maxRsis = MaxIndicator.compute(rsisSplice[2])

        let result = Divide(
            Subtract(rsisSplice[0], minRsisSplice[0]),
            Subtract(maxRsis, minRsisSplice[1])
        )

        return result
    }

    // IdlePeriod = RSI.IdlePeriod + Min/Max.IdlePeriod
    public func idlePeriod(): Int64 {
        return RsiIndicator.idlePeriod() + MinIndicator.idlePeriod()
    }
}
