package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * MovingMin 移动最小值指标
 *
 * 计算指定周期内的最小值。
 *
 * ### 算法原理
 * 使用有序集合维护滑动窗口内的数据，实时获取窗口最小值。
 *
 * ### 特性
 * - 对价格谷值敏感
 * - 常用于支撑位判断
 * - 滞后性较小
 *
 * @param period 移动窗口周期
 */
public class MovingMin {
    // 周期
    public var period: Int64 = 1

    /**
     * 默认构造函数
     * 使用默认周期1
     */
    public MovingMin() {
        // 使用默认值 1
    }

    /**
     * 带参数构造函数
     * @param period 移动窗口周期
     */
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

        let orderedSet = OrderedSet()

        let minValues = operate(duplicatedValues[0], duplicatedValues[1], { value: Float64, boundary: Float64 =>
            orderedSet.insert(value)
            orderedSet.remove(boundary)
            return orderedSet.min()
        })

        return skip(minValues, period - 1)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}
