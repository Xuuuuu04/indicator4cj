package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultRocPeriod: Int64 = 9

// Rate Of Change (ROC) = (price - price_n) / price_n
public class Roc {
    public var period: Int64 = DefaultRocPeriod

    public Roc() {
        this.period = period
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
        let window = Ring<Float64>(this.period)
        var rocs = Map(values, { v: Float64 =>
            var res: Float64 = 0.0
            if (window.IsFull()) {
                match (window.Get()) {
                    case Some(p) =>
                        if (p != 0.0) {
                            res = (v - p) / p
                        }
                    case None => ()
                }
            }
            window.Put(v)
            return res
        })
        rocs = Skip(rocs, idlePeriod())
        return rocs
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period }

// toString 返回指标的字符串表示。
    public func toString(): String { return "ROC(${this.period})" }
}
