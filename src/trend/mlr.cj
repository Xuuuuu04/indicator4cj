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

// compute 计算线性回归预测值。
    public func compute(x: Iterator<Float64>, y: Iterator<Float64>): Iterator<Float64> {
        // 需要两份 x：一份给 Mls 计算斜率截距，一份用于生成预测值
        let xCopies = duplicate(x, 2)
        let (mIter, bIter) = MlsIndicator.compute(xCopies[0], y)
        
        let xShifted = skip(xCopies[1], MlsIndicator.idlePeriod())
        
        let mx = operate(mIter, xShifted, { a: Float64, b: Float64 => a * b })
        return add(mx, bIter)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return MlsIndicator.idlePeriod() }

// toString 返回指标的字符串表示。
    public func toString(): String { return "MLR(${MlsIndicator.Sum.period})" }
}

