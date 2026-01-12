package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// Money Flow Volume (Float64).
public class Mfv {
    private let _mfm = Mfm()

    public init() {}

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return Multiply(
            _mfm.Compute(highs, lows, closings),
            volumes
        )
    }

    public func IdlePeriod(): Int64 { return 0 }
}

