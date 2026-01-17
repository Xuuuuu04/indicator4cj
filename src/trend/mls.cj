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

/**
 * compute 计算移动最小二乘法
 *
 * 计算线性回归的斜率(m)和截距。
 *
 * @param xValues 自变量X迭代器(通常是时间或索引)
 * @param yValues 因变量Y迭代器(价格数据)
 * @return 元组：(斜率迭代器, 截距迭代器)
 */
    public func compute(
        xValues: Iterator<Float64>,
        yValues: Iterator<Float64>
    ): (Iterator<Float64>, Iterator<Float64>) {
        let xDuplicates = duplicate(xValues, 3)
        let yDuplicates = duplicate(yValues, 2)

        let sumXY = Sum.compute(
            operate(xDuplicates[0], yDuplicates[0], { a: Float64, b: Float64 => a * b })
        )

        let sumXSplice = duplicate(Sum.compute(xDuplicates[1]), 4)
        let sumYSplice = duplicate(Sum.compute(yDuplicates[1]), 2)
        let sumX2 = Sum.compute(pow(xDuplicates[2], 2.0))

        // m = (周期 * sumXY - sumX * sumY) / (周期 * sumX2 - sumX * sumX)
        let slopeSplice = duplicate(
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
        let intercept = divideBy(
            subtract(
                sumYSplice[1],
                multiply(slopeSplice[1], sumXSplice[3])
            ),
            Float64(Sum.period)
        )

        return (slopeSplice[0], intercept)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return Sum.idlePeriod() }
}
