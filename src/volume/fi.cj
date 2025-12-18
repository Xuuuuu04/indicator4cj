package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Force Index.
public class Fi {
    private let ema = Ema()

    public init() { ema.Period = 13 }
    public init(period: Int64) { ema.Period = period }

    public func Compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return ema.Compute(
            Multiply(
                Change(closings, 1),
                volumes
            )
        )
    }

    public func IdlePeriod(): Int64 { return ema.IdlePeriod() + 1 }
}

