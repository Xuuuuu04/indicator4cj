package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Moving minimum over window using Float64 Bst.
public class MovingMin {
    public var Period: Int64

    public init() { this.Period = 1 }
    public init(period: Int64) { this.Period = period }

    public func Compute(c: Iterator<Float64>): Iterator<Float64> {
        let cs = Duplicate(c, 2)
        cs[1] = Shift(cs[1], Period, 0.0)

        let bst = Bst()

        let mins = Operate(cs[0], cs[1], { v: Float64, b: Float64 =>
            bst.Insert(v)
            bst.Remove(b)
            return bst.Min()
        })

        return Skip(mins, Period - 1)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

