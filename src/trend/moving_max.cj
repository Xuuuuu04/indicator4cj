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
        let cs = duplicate(c, 2)
        cs[1] = shift(cs[1], period, 0.0)

        let bst = Bst()

        let maxs = operate(cs[0], cs[1], { v: Float64, b: Float64 =>
            bst.insert(v)
            bst.remove(b)
            return bst.max()
        })

        return skip(maxs, period - 1)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}
