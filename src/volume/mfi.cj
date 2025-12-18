package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Mfi {
    private let TypicalPrice = TypicalPrice()
    private let Sum = MovingSum()

    public init() {
        Sum.Period = 14
    }

    public init(period: Int64) {
        Sum.Period = period
    }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let rawFlowSplice = Duplicate(
            Multiply(
                TypicalPrice.Compute(highs, lows, closings),
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
            Sum.Compute(KeepPositives(moneyFlowSplice[0])),
            Sum.Compute(MultiplyBy(KeepNegatives(moneyFlowSplice[1]), -1.0))
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

    public func IdlePeriod(): Int64 { return Sum.IdlePeriod() + 1 }
}

