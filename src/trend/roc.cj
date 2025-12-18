package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultRocPeriod: Int64 = 9

// Rate Of Change (ROC) = (price - price_n) / price_n
public class Roc {
    public var Period: Int64

    public init() { this.Period = DefaultRocPeriod }
    public init(period: Int64) {
        if (period <= 0) {
            this.Period = DefaultRocPeriod
        } else {
            this.Period = period
        }
    }

    public func Compute(values: Iterator<Float64>): Iterator<Float64> {
        let window = Ring<Float64>(Period)
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
        rocs = Skip(rocs, IdlePeriod())
        return rocs
    }

    public func IdlePeriod(): Int64 { return Period }

    public func toString(): String { return "ROC(${Period})" }
}

public func NewRoc(): Roc { return Roc() }
public func NewRocWithPeriod(period: Int64): Roc { return Roc(period) }


