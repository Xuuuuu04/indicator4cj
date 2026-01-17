package indicator4cj.helper

/**
 * keepNegatives 保留负数，非负数置零
 *
 * 过滤迭代器中的元素，保留负数，将非负数（零和正数）置零。
 * 常用于计算平均跌幅时，只保留跌幅部分（转换为绝对值）。
 *
 * ### 示例
 * ```cangjie
 * let changes = [1.5, -0.8, 2.3, 0.0, -1.2]
 * let negatives = keepNegatives(changes.iterator())
 * // 结果: [0.0, -0.8, 0.0, 0.0, -1.2]
 * ```
 *
 * @param iter 浮点数迭代器
 * @return 负数保留、非负数置零的迭代器
 */
public func keepNegatives(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v =>
        if (v < 0.0) { return v }
        return 0.0
    })
}

