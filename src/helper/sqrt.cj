package indicator4cj.helper

import std.math.*

/**
 * sqrt 平方根
 *
 * 对迭代器每个元素计算平方根。
 *
 * ### 示例
 * ```cangjie
 * let data = [1.0, 4.0, 9.0, 16.0, 25.0]
 * let result = sqrt(data.iterator())
 * // 结果: [1.0, 2.0, 3.0, 4.0, 5.0]
 * ```
 *
 * @param iter 输入迭代器
 * @return 平方根结果迭代器
 */
public func sqrt(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v => sqrt(v) })
}

