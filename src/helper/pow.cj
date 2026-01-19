package indicator4cj.helper

import std.math.*

/**
 * pow 幂运算
 *
 * 对迭代器每个元素进行幂运算。
 *
 * ### 示例
 * ```cangjie
 * let data = [1.0, 2.0, 3.0, 4.0]
 * let result = pow(data.iterator(), 2.0)
 * // 结果: [1.0, 4.0, 9.0, 16.0]
 *
 * let squares = pow(data.iterator(), 3.0)
 * // 结果: [1.0, 8.0, 27.0, 64.0]
 * ```
 *
 * @param iter 输入迭代器
 * @param exp 指数
 * @return 幂运算结果迭代器
 */
public func pow(iter: Iterator<Float64>, exp: Float64): Iterator<Float64> {
    return apply(iter, { v => pow(v, exp) })
}

