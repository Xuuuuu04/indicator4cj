package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// Money Flow Multiplier (Float64).
public class Mfm {
    public init() {}

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)
        let cs = Duplicate(closings, 2)
        return Divide(
            Subtract(
                Subtract(cs[0], ls[0]),
                Subtract(hs[0], cs[1])
            ),
            Subtract(hs[1], ls[1])
        )
    }

    public func idlePeriod(): Int64 { return 0 }
}

