package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Stochastic Oscillator: %K = 100 * (Close - LowN) / (HighN - LowN)
// %D = SMA(%K, period)
public class StochasticOscillator {
    // 周期
    public var period: Int64 = 14

    public StochasticOscillator() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算随机振荡器指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let hh = MovingMax(period).compute(highs)
        let ll = MovingMin(period).compute(lows)
        let closeAdj = Skip(closes, period - 1)

        let k = MultiplyBy(
            Divide(
                Subtract(closeAdj, ll),
                Subtract(hh, ll)
            ),
            100.0
        )

        let sma = Sma()
        sma.period = period
        let d = sma.compute(k)

        return (k, d)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

