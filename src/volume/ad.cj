package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// Accumulation/Distribution.
public class Ad {
    private let _mfv = Mfv()

    public init() {}

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let mfvs = _mfv.compute(highs, lows, closings, volumes)
        return MapWithPrevious(mfvs, { prev: Float64, cur: Float64 => prev + cur }, 0.0)
    }

    public func idlePeriod(): Int64 { return 0 }
}

