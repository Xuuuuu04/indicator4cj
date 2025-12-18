package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Williams %R = -100 * (HighestHigh - Close) / (HighestHigh - LowestLow)
public class WilliamsR {
    public var Period: Int64

    public init() { this.Period = 14 }
    public init(period: Int64) { this.Period = period }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        let hh = MovingMax(Period).Compute(highs)
        let ll = MovingMin(Period).Compute(lows)

        let closesAdj = Skip(closes, Period - 1)

        return Operate3(hh, ll, closesAdj, { h: Float64, l: Float64, c: Float64 =>
            let denom = h - l
            if (denom == 0.0) { return 0.0 }
            return -100.0 * (h - c) / denom
        })
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

