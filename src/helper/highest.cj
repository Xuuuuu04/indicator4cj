package indicator4cj.helper

import std.collection.*

/**
 * highest 窗口内最大值
 *
 * 计算滑动窗口内的最大值。
 * 对每个位置，返回其之前 w 个元素（含自身）的最大值。
 *
 * 示例：highest([1, 3, 2, 5, 4], 3) => [1, 3, 3, 5, 5]
 * 解释：
 * - 位置 0: 窗口 [1]，最大值 1
 * - 位置 1: 窗口 [1, 3]，最大值 3
 * - 位置 2: 窗口 [1, 3, 2]，最大值 3
 * - 位置 3: 窗口 [3, 2, 5]，最大值 5
 * - 位置 4: 窗口 [2, 5, 4]，最大值 5
 *
 * @param iter 数值迭代器
 * @param w 窗口大小
 * @return 窗口最大值迭代器
 */
public func highest(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return window(iter, w, { buf, _ => maxInList(buf) })
}

/**
 * maxInList 计算列表最大值
 *
 * @param buf 数值列表
 * @return 最大值
 */
private func maxInList(buf: ArrayList<Float64>): Float64 {
    var m = buf[0]
    for (i in 1..buf.size) {
        let v = buf[i]
        if (v > m) { m = v }
    }
    return m
}

