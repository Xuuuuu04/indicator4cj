package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Weighted Close = (High + Low + (Close * 2)) / 4
public class WeightedClose {
    public init() {}

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        return Operate3(highs, lows, closes, { h: Float64, l: Float64, c: Float64 =>
            return (h + l + (c * 2.0)) / 4.0
        })
    }

    public func IdlePeriod(): Int64 { return 0 }

    public func toString(): String { return "Weighted Close" }
}

public func NewWeightedClose(): WeightedClose {
    return WeightedClose()
}


