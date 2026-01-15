package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Mfi {
    private let typicalPrice = TypicalPrice()
    private let sum = MovingSum()

    public init() {
        sum.period = 14
    }

    public init(period: Int64) {
        sum.period = period
    }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let rawFlowSplice = Duplicate(
            Multiply(
                typicalPrice.compute(highs, lows, closings),
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
            sum.compute(KeepPositives(moneyFlowSplice[0])),
            sum.compute(MultiplyBy(KeepNegatives(moneyFlowSplice[1]), -1.0))
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

    public func idlePeriod(): Int64 { return sum.idlePeriod() + 1 }
}

