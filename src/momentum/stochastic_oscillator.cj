package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Stochastic Oscillator: %K = 100 * (Close - LowN) / (HighN - LowN)
// %D = SMA(%K, period)
public class StochasticOscillator {
    public var Period: Int64

    public init() { this.Period = 14 }
    public init(period: Int64) { this.Period = period }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let hh = MovingMax(Period).Compute(highs)
        let ll = MovingMin(Period).Compute(lows)
        let closeAdj = Skip(closes, Period - 1)

        let k = MultiplyBy(
            Divide(
                Subtract(closeAdj, ll),
                Subtract(hh, ll)
            ),
            100.0
        )

        let sma = Sma()
        sma.Period = Period
        let d = sma.Compute(k)

        return (k, d)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

