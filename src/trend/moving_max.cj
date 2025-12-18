package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Moving maximum over window using Float64 Bst.
public class MovingMax {
    public var Period: Int64

    public init() { this.Period = 1 }
    public init(period: Int64) { this.Period = period }

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        let cs = Duplicate(c, 2)
        cs[1] = Shift(cs[1], Period, 0.0)

        let bst = Bst()

        let maxs = Operate(cs[0], cs[1], { v: Float64, b: Float64 =>
            bst.Insert(v)
            bst.Remove(b)
            return bst.Max()
        })

        return Skip(maxs, Period - 1)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

