package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Moving maximum over window using Float64 Bst.
public class MovingMax {
    // 周期
    public var period: Int64 = 1

    public MovingMax() {
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

        let maxs = Operate(cs[0], cs[1], { v: Float64, b: Float64 =>
            bst.Insert(v)
            bst.Remove(b)
            return bst.Max()
        })

        return Skip(maxs, this.period - 1)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return this.period - 1 }
}
