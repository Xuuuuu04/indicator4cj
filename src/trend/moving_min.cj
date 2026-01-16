package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Moving minimum over window using Float64 Bst.
public class MovingMin {
    // 周期
    public var period: Int64 = 1

    public MovingMin() {
        this.period = period
    }

    public init(period: Int64) {
        this.period = period
    }

// compute 计算指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let cs = Duplicate(c, 2)
        cs[1] = Shift(cs[1], this.period, 0.0)

        let bst = Bst()

        let mins = Operate(cs[0], cs[1], { v: Float64, b: Float64 =>
            bst.Insert(v)
            bst.Remove(b)
            return bst.Min()
        })

        return Skip(mins, this.period - 1)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}
