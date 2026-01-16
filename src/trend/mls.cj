package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// 移动最小二乘法（斜率 m 和截距 b）。
public class Mls {
    // 移动求和
    public let Sum: MovingSum

    public Mls(period: Int64) {
        this.Sum = MovingSum(period)
    }

// compute 计算指标。
    public func compute(x: Iterator<Float64>, y: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let xSplice = duplicate(x, 3)
        let ySplice = duplicate(y, 2)

        let sumXY = Sum.compute(
            operate(xSplice[0], ySplice[0], { a: Float64, b: Float64 => a * b })
        )

        let sumXSplice = duplicate(Sum.compute(xSplice[1]), 4)
        let sumYSplice = duplicate(Sum.compute(ySplice[1]), 2)
        let sumX2 = Sum.compute(pow(xSplice[2], 2.0))

        // m = (周期 * sumXY - sumX * sumY) / (周期 * sumX2 - sumX * sumX)
        let mSplice = duplicate(
            divide(
                subtract(
                    multiplyBy(sumXY, Float64(Sum.period)),
                    multiply(sumXSplice[0], sumYSplice[0])
                ),
                subtract(
                    multiplyBy(sumX2, Float64(Sum.period)),
                    multiply(sumXSplice[1], sumXSplice[2])
                )
            ),
            2
        )

        // b = (sumY - m * sumX) / 周期
        let b = divideBy(
            subtract(
                sumYSplice[1],
                multiply(mSplice[1], sumXSplice[3])
            ),
            Float64(Sum.period)
        )

        return (mSplice[0], b)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return Sum.idlePeriod() }
}
