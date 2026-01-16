package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class Mfi {
    private let _typicalPrice = TypicalPrice()
    private let _sum = MovingSum()

    public Mfi() {
        _sum.period = 14
    }

    public init(period: Int64) {
        _sum.period = period
    }

    // compute 计算资金流量指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let rawFlowSplice = duplicate(
            multiply(
                _typicalPrice.compute(highs, lows, closings),
                volumes
            ),
            2
        )

        let moneyFlowSplice = duplicate(
            multiply(
                sign(change(rawFlowSplice[0], 1)),
                skip(rawFlowSplice[1], 1)
            ),
            2
        )

        let moneyRatio = divide(
            _sum.compute(keepPositives(moneyFlowSplice[0])),
            _sum.compute(multiplyBy(keepNegatives(moneyFlowSplice[1]), -1.0))
        )

        return incrementBy(
            multiplyBy(
                pow(
                    incrementBy(moneyRatio, 1.0),
                    -1.0
                ),
                -100.0
            ),
            100.0
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _sum.idlePeriod() + 1 }
}

