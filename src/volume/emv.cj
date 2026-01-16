package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Ease of Movement.
public class Emv {
    private let sma = Sma()

    public Emv() { sma.period = 14 }
    public init(period: Int64) { sma.period = period }

    // compute 计算 ease of movement 指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
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

        return sma.compute(
            Divide(distanceMoved, boxRatio)
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return sma.idlePeriod() + 1 }
}

