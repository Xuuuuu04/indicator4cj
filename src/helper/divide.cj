package indicator4cj.helper

/**
 * divide 逐元素相除
 *
 * 对两个迭代器对应位置的元素进行除法运算。
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

