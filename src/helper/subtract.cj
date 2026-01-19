package indicator4cj.helper

/**
 * subtract 逐元素相减
 *
 * 对两个迭代器对应位置的元素进行减法运算（第一个减第二个）。
 *
 * ### 示例
 * ```cangjie
 * let a = [10.0, 20.0, 30.0]
 * let b = [1.0, 2.0, 3.0]
 * let result = subtract(a.iterator(), b.iterator())
 * // 结果: [9.0, 18.0, 27.0]
 * ```
 *
 * @param minuend 被减数迭代器
 * @param subtrahend 减数迭代器
 * @return 减法结果迭代器
 */
public func subtract(
    minuend: Iterator<Float64>,
    subtrahend: Iterator<Float64>
): Iterator<Float64> {
    return operate(minuend, subtrahend, { x, y => x - y })
}

