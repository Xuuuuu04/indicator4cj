package indicator4cj.helper

/**
 * divide 逐元素相除
 *
 * 对两个迭代器对应位置的元素进行除法运算。
 *
 * ### 示例
 * ```cangjie
 * let a = [100.0, 200.0, 300.0]
 * let b = [10.0, 20.0, 30.0]
 * let result = divide(a.iterator(), b.iterator())
 * // 结果: [10.0, 10.0, 10.0]
 * ```
 *
 * @param dividend 被除数迭代器
 * @param divisor 除数迭代器
 * @return 除法结果迭代器
 */
public func divide(
    dividend: Iterator<Float64>,
    divisor: Iterator<Float64>
): Iterator<Float64> {
    return operate(dividend, divisor, { left, right => left / right })
}

