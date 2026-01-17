package indicator4cj.helper

/**
 * sign 返回数值符号
 *
 * 对迭代器中的每个元素返回其符号：
 * - 正数返回 1.0
 * - 零返回 0.0
 * - 负数返回 -1.0
 *
 * 示例：sign([-2.5, 0, 3.7]) => [-1.0, 0.0, 1.0]
 *
 * @param iter 数值迭代器
 * @return 符号迭代器，值为 -1.0、0.0 或 1.0
 */
public func sign(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v =>
        if (v > 0.0) {
            return 1.0
        } else if (v < 0.0) {
            return -1.0
        }
        return 0.0
    })
}

