package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Stochastic Oscillator: %K = 100 * (Close - LowN) / (HighN - LowN)
// %D = SMA(%K, period)
public class StochasticOscillator {
    public var period: Int64

    public StochasticOscillator() { this.period = 14 }
    public init(period: Int64) { this.period = period }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let hh = MovingMax(this.period).compute(highs)
        let ll = MovingMin(this.period).compute(lows)
        let closeAdj = Skip(closes, this.period - 1)

        let k = MultiplyBy(
            Divide(
                Subtract(closeAdj, ll),
                Subtract(hh, ll)
            ),
            100.0
        )

        let sma = Sma()
        sma.period = this.period
        let d = sma.compute(k)

        return (k, d)
    }

    public func idlePeriod(): Int64 { return this.period - 1 }
}

