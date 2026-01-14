package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Force Index.
public class Fi {
    private let _ema = Ema()

    public init() { _ema.Period = 13 }
    public init(period: Int64) { _ema.Period = period }

    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return _ema.compute(
            Multiply(
                Change(closings, 1),
                volumes
            )
        )
    }

    public func idlePeriod(): Int64 { return _ema.idlePeriod() + 1 }
}

