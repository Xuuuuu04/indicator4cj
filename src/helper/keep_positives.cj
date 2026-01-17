package indicator4cj.helper

/**
 * keepPositives 保留正数，非正数置零
 *
 * 过滤迭代器中的元素，保留正数，将非正数（零和负数）置零。
 * 常用于计算平均涨幅时，只保留涨幅部分。
 *
 * ### 示例
 * ```cangjie
 * let changes = [1.5, -0.8, 2.3, 0.0, -1.2]
 * let positives = keepPositives(changes.iterator())
 * // 结果: [1.5, 0.0, 2.3, 0.0, 0.0]
 * ```
 *
 * @param iter 浮点数迭代器
 * @return 正数保留、非正数置零的迭代器
 */
public func keepPositives(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v =>
        if (v > 0.0) { return v }
        return 0.0
    })
}

