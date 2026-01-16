package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// Accumulation/Distribution.
public class Ad {
    private let mfv = Mfv()

    public init() {}

    // compute 计算累积/分布指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let mfvs = mfv.compute(highs, lows, closings, volumes)
        return MapWithPrevious(mfvs, { prev: Float64, cur: Float64 => prev + cur }, 0.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 0 }
}

