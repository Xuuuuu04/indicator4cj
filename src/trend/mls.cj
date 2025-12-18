package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Moving Least Squares (slope m and intercept b).
public class Mls {
    public let Sum: MovingSum

    public init(period: Int64) {
        this.Sum = MovingSum(period)
    }

    public func Compute(x: Iterator<Float64>, y: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let xSplice = Duplicate(x, 3)
        let ySplice = Duplicate(y, 2)

        let sumXY = Sum.Compute(
            Operate(xSplice[0], ySplice[0], { a: Float64, b: Float64 => a * b })
        )

        let sumXSplice = Duplicate(Sum.Compute(xSplice[1]), 4)
        let sumYSplice = Duplicate(Sum.Compute(ySplice[1]), 2)
        let sumX2 = Sum.Compute(Pow(xSplice[2], 2.0))

        // m = (period * sumXY - sumX * sumY) / (period * sumX2 - sumX * sumX)
        let mSplice = Duplicate(
            Divide(
                Subtract(
                    MultiplyBy(sumXY, Float64(Sum.Period)),
                    Multiply(sumXSplice[0], sumYSplice[0])
                ),
                Subtract(
                    MultiplyBy(sumX2, Float64(Sum.Period)),
                    Multiply(sumXSplice[1], sumXSplice[2])
                )
            ),
            2
        )

        // b = (sumY - m * sumX) / period
        let b = DivideBy(
            Subtract(
                sumYSplice[1],
                Multiply(mSplice[1], sumXSplice[3])
            ),
            Float64(Sum.Period)
        )

        return (mSplice[0], b)
    }

    public func IdlePeriod(): Int64 { return Sum.IdlePeriod() }
}
