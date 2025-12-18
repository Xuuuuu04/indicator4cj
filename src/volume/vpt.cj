package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// VPT：Volume Price Trend（Float64）。
public class Vpt {
    public init() {}

    public func Compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let ratios = Multiply(
            ChangeRatio(closings, 1),
            Skip(volumes, 1)
        )
        return MapWithPrevious(ratios, { prev: Float64, curr: Float64 => prev + curr }, 0.0)
    }

    public func IdlePeriod(): Int64 { return 1 }
}

