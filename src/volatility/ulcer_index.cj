package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class UlcerIndex {
    public var period: Int64 = 14

    public init() { this.period = period }
    public init(period: Int64) { this.period = period }

    // compute 计算溃疡指数指标。
    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let cs = Duplicate(closings, 2)

        let movingMax = MovingMax(this.period)
        let highs = Duplicate(movingMax.compute(cs[0]), 2)

        cs[1] = Skip(cs[1], movingMax.idlePeriod())

        let drawdown = MultiplyBy(
            Divide(
                Subtract(cs[1], highs[0]),
                highs[1]
            ),
            100.0
        )

        let sma = Sma()
        sma.period = this.period
        let squaredAvg = Pow(sma.compute(drawdown), 2.0)

        return Sqrt(squaredAvg)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return (this.period - 1) * 2 }
}

