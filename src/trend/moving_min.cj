package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Moving minimum over window using Float64 Bst.
public class MovingMin {
    // 周期
    public var period: Int64 = 1

    public MovingMin() {
        // 使用默认值 1
    }

    public init(period: Int64) {
        this.period = period
    }

/**
 * compute 计算移动最小值
 *
 * 计算指定周期内的最小值。
 *
 * @param values 价格数据迭代器
 * @return 移动最小值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let duplicatedValues = duplicate(values, 2)
        duplicatedValues[1] = shift(duplicatedValues[1], period, 0.0)

        let bst = Bst()

        let minValues = operate(duplicatedValues[0], duplicatedValues[1], { value: Float64, boundary: Float64 =>
            bst.insert(value)
            bst.remove(boundary)
            return bst.min()
        })

        return skip(minValues, period - 1)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}
