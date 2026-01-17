package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultRocPeriod: Int64 = 9

// 变化率(ROC) = (当前价格 - n周期前价格) / n周期前价格
public class Roc {
    // 周期
    public var period: Int64 = DefaultRocPeriod

    public Roc() {
        // 使用默认值
    }

    public init(period: Int64) {
        if (period <= 0) {
            this.period = DefaultRocPeriod
        } else {
            this.period = period
        }
    }

// compute 计算指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let window = Ring<Float64>(period)
        var rocs = map(values, { v: Float64 =>
            var res: Float64 = 0.0
            if (window.isFull()) {
                match (window.get()) {
                    case Some(p) =>
                        if (p != 0.0) {
                            res = (v - p) / p
                        }
                    case None => ()
                }
            }
            window.put(v)
            return res
        })
        rocs = skip(rocs, idlePeriod())
        return rocs
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period }

// toString 返回指标的字符串表示。
    public func toString(): String { return "ROC(${period})" }
}
