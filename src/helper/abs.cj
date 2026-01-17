package indicator4cj.helper

import std.math.*

/**
 * abs 计算绝对值
 *
 * 对数值迭代器中的每个元素取绝对值，返回包含绝对值的新迭代器。
 * 负数转为正数，正数和零保持不变。
 *
 * @param iter 数值迭代器
 * @return 绝对值迭代器
 */
public func abs(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v => abs(v) })
}

