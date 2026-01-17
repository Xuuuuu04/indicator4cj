package indicator4cj.helper

import std.collection.*

/**
 * lowest 窗口内最小值
 *
 * 计算滑动窗口内的最小值。
 * 对每个位置，返回其之前 w 个元素（含自身）的最小值。
 *
 * 示例：lowest([5, 3, 2, 4, 1], 3) => [5, 3, 2, 2, 1]
 * 解释：
 * - 位置 0: 窗口 [5]，最小值 5
 * - 位置 1: 窗口 [5, 3]，最小值 3
 * - 位置 2: 窗口 [5, 3, 2]，最小值 2
 * - 位置 3: 窗口 [3, 2, 4]，最小值 2
 * - 位置 4: 窗口 [2, 4, 1]，最小值 1
 *
 * @param iter 数值迭代器
 * @param w 窗口大小
 * @return 窗口最小值迭代器
 */
public func lowest(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return window(iter, w, { buf, _ => minInList(buf) })
}

/**
 * minInList 计算列表最小值
 *
 * @param buf 数值列表
 * @return 最小值
 */
private func minInList(buf: ArrayList<Float64>): Float64 {
    var m = buf[0]
    for (i in 1..buf.size) {
        let v = buf[i]
        if (v < m) { m = v }
    }
    return m
}

