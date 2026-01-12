package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Force Index.
public class Fi {
    private let _ema = Ema()

    public init() { _ema.Period = 13 }
    public init(period: Int64) { _ema.Period = period }

    public func Compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return _ema.Compute(
            Multiply(
                Change(closings, 1),
                volumes
            )
        )
    }

    public func IdlePeriod(): Int64 { return _ema.IdlePeriod() + 1 }
}

