package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class ChandelierExit {
    // 周期
    public var period: Int64 = 22
    // 倍数
    public var multiplier: Float64 = 3.0

    public ChandelierExit() {
        this.period = period
        this.multiplier = multiplier
    }

    public init(period: Int64, multiplier: Float64) {
        this.period = period
        this.multiplier = multiplier
    }

    // compute 计算吊灯退出指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let hs = duplicate(highs, 2)
        let ls = duplicate(lows, 2)

        let movingMax = MovingMax(period)
        let movingMin = MovingMin(period)
        let atr = Atr(period)

        let skipMax = atr.idlePeriod() - movingMax.idlePeriod()
        let skipMin = atr.idlePeriod() - movingMin.idlePeriod()

        let maxHighs = skip(movingMax.compute(hs[0]), skipMax)
        let minLows = skip(movingMin.compute(ls[0]), skipMin)

        let atrScaled = duplicate(
            multiplyBy(
                atr.compute(hs[1], ls[1], closings),
                multiplier
            ),
            2
        )

        let ceLong = subtract(maxHighs, atrScaled[0])
        let ceShort = add(minLows, atrScaled[1])

        return (ceLong, ceShort)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period }
}

