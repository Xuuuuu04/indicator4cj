package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Williams %R = -100 * (HighestHigh - Close) / (HighestHigh - LowestLow)
public class WilliamsR {
    public var period: Int64

    public init() { this.period = 14 }
    public init(period: Int64) { this.period = period }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        let hh = MovingMax(this.period).compute(highs)
        let ll = MovingMin(this.period).compute(lows)

        let closesAdj = Skip(closes, this.period - 1)

        return Operate3(hh, ll, closesAdj, { h: Float64, l: Float64, c: Float64 =>
            let denom = h - l
            if (denom == 0.0) { return 0.0 }
            return -100.0 * (h - c) / denom
        })
    }

    public func idlePeriod(): Int64 { return this.period - 1 }
}

