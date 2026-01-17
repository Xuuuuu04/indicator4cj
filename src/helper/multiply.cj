package indicator4cj.helper

/**
 * multiply 逐元素相乘
 *
 * 对两个迭代器对应位置的元素进行乘法运算。
 *
 * @param left 第一个乘数迭代器
 * @param right 第二个乘数迭代器
 * @return 乘法结果迭代器
 */
public func multiply(
    left: Iterator<Float64>,
    right: Iterator<Float64>
): Iterator<Float64> {
    return operate(left, right, { x, y => x * y })
}

