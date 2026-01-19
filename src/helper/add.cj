package indicator4cj.helper

/**
 * add 逐元素相加
 *
 * 对两个迭代器对应位置的元素进行加法运算。
 *
 * ### 示例
 * ```cangjie
 * let a = [1.0, 2.0, 3.0]
 * let b = [10.0, 20.0, 30.0]
 * let result = add(a.iterator(), b.iterator())
 * // 结果: [11.0, 22.0, 33.0]
 * ```
 *
 * @param left 第一个加数迭代器
 * @param right 第二个加数迭代器
 * @return 加法结果迭代器
 */
public func add(
    left: Iterator<Float64>,
    right: Iterator<Float64>
): Iterator<Float64> {
    return operate(left, right, { x, y => x + y })
}

