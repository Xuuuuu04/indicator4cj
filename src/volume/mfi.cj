package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Mfi {
    private let _typicalPrice = TypicalPrice()
    private let _sum = MovingSum()

    public init() {
        _sum.Period = 14
    }

    public init(period: Int64) {
        _sum.Period = period
    }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let rawFlowSplice = Duplicate(
            Multiply(
                _typicalPrice.compute(highs, lows, closings),
                volumes
            ),
            2
        )

        let moneyFlowSplice = Duplicate(
            Multiply(
                Sign(Change(rawFlowSplice[0], 1)),
                Skip(rawFlowSplice[1], 1)
            ),
            2
        )

        let moneyRatio = Divide(
            _sum.compute(KeepPositives(moneyFlowSplice[0])),
            _sum.compute(MultiplyBy(KeepNegatives(moneyFlowSplice[1]), -1.0))
        )

        return IncrementBy(
            MultiplyBy(
                Pow(
                    IncrementBy(moneyRatio, 1.0),
                    -1.0
                ),
                -100.0
            ),
            100.0
        )
    }

    public func idlePeriod(): Int64 { return _sum.idlePeriod() + 1 }
}

