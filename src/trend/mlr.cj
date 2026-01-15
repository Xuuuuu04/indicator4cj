package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// MLR：基于最小二乘的线性回归预测 y_hat = m*x + b
public class Mlr {
    public let MlsIndicator: Mls

    public init(period: Int64) {
        this.MlsIndicator = Mls(period)
    }

    public func compute(x: Iterator<Float64>, y: Iterator<Float64>): Iterator<Float64> {
        // 需要两份 x：一份给 Mls 计算斜率截距，一份用于生成预测值
        let xCopies = Duplicate(x, 2)
        let (mIter, bIter) = MlsIndicator.compute(xCopies[0], y)
        
        let xShifted = Skip(xCopies[1], MlsIndicator.idlePeriod())
        
        let mx = Operate(mIter, xShifted, { a: Float64, b: Float64 => a * b })
        return Add(mx, bIter)
    }

    public func idlePeriod(): Int64 { return MlsIndicator.idlePeriod() }

    public func toString(): String { return "MLR(${MlsIndicator.Sum.period})" }
}

