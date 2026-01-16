package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Ease of Movement.
public class Emv {
    private let _sma = Sma()

    public Emv() {
        _sma.period = 14
    }

    public init(period: Int64) {
        _sma.period = period
    }

    // compute 计算 ease of movement 指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let hs = duplicate(highs, 2)
        let ls = duplicate(lows, 2)

        let distanceMoved = change(
            divideBy(
                add(hs[0], ls[0]),
                2.0
            ),
            1
        )

        let boxRatio = divide(
            divideBy(volumes, 100000000.0),
            subtract(hs[1], ls[1])
        )

        return _sma.compute(
            divide(distanceMoved, boxRatio)
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _sma.idlePeriod() + 1 }
}

