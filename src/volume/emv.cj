package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Ease of Movement.
public class Emv {
    private let _sma = Sma()

    public init() { _sma.Period = 14 }
    public init(period: Int64) { _sma.Period = period }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)

        let distanceMoved = Change(
            DivideBy(
                Add(hs[0], ls[0]),
                2.0
            ),
            1
        )

        let boxRatio = Divide(
            DivideBy(volumes, 100000000.0),
            Subtract(hs[1], ls[1])
        )

        return _sma.Compute(
            Divide(distanceMoved, boxRatio)
        )
    }

    public func IdlePeriod(): Int64 { return _sma.IdlePeriod() + 1 }
}

