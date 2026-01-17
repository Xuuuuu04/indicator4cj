package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// MLR：基于最小二乘的线性回归预测 y_hat = m*x + b
public class Mlr {
    // 最小二乘
    public let MlsIndicator: Mls

    public Mlr(period: Int64) {
        this.MlsIndicator = Mls(period)
    }

/**
 * compute 计算线性回归预测值
 *
 * 基于最小二乘法进行线性回归预测。
 * 公式：y_hat = m*x + b
 *
 * @param xValues 自变量X迭代器
 * @param yValues 因变量Y迭代器
 * @return 预测值迭代器
 */
    public func compute(
        xValues: Iterator<Float64>,
        yValues: Iterator<Float64>
    ): Iterator<Float64> {
        // 需要两份 x：一份给 Mls 计算斜率截距，一份用于生成预测值
        let xDuplicates = duplicate(xValues, 2)
        let (slopeIter, interceptIter) = MlsIndicator.compute(xDuplicates[0], yValues)

        let xShifted = skip(xDuplicates[1], MlsIndicator.idlePeriod())

        let predictedX = operate(slopeIter, xShifted, { a: Float64, b: Float64 => a * b })
        return add(predictedX, interceptIter)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return MlsIndicator.idlePeriod() }

// toString 返回指标的字符串表示。
    public func toString(): String { return "MLR(${MlsIndicator.Sum.period})" }
}

