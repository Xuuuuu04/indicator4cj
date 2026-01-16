package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class UlcerIndex {
    // 周期
    public var period: Int64 = 14

    public init() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算溃疡指数指标。
    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let cs = duplicate(closings, 2)

        let movingMax = MovingMax(period)
        let highs = duplicate(movingMax.compute(cs[0]), 2)

        cs[1] = skip(cs[1], movingMax.idlePeriod())

        let drawdown = multiplyBy(
            divide(
                subtract(cs[1], highs[0]),
                highs[1]
            ),
            100.0
        )

        let sma = Sma()
        sma.period = period
        let squaredAvg = pow(sma.compute(drawdown), 2.0)

        return sqrt(squaredAvg)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return (period - 1) * 2 }
}

