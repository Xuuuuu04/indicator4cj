package indicator4cj.helper

import std.collection.*

/**
 * maxSince 自最近最大值以来的步数
 *
 * 返回每个元素自最近最大值起经过的步数（含自身）。
 * 使用滑动窗口，窗口大小为 w。
 *
 * 计算逻辑：
 * 1. 在窗口内查找最大值
 * 2. 从当前元素向前回溯，计算距离最近最大值的步数
 * 3. 如果当前元素就是最大值，返回 0
 *
 * 示例：maxSince([1, 3, 2, 5, 4], 3) => [0, 0, 1, 0, 1]
 * 解释：
 * - 1: 窗口 [1]，最大值 1，距离 0
 * - 3: 窗口 [1,3]，最大值 3，距离 0
 * - 2: 窗口 [1,3,2]，最大值 3，距离 1
 * - 5: 窗口 [3,2,5]，最大值 5，距离 0
 * - 4: 窗口 [2,5,4]，最大值 5，距离 1
 *
 * @param iter 数值迭代器
 * @param w 滑动窗口大小
 * @return 步数迭代器
 */
public func maxSince(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return window<Float64>(iter, w, { buf, _ =>
        if (buf.isEmpty()) {
            return Float64(0)
        }
        var m = buf[0]
        for (i in 1..buf.size) {
            let v = buf[i]
            if (v > m) {
                m = v
            }
        }

        var since: Int64 = 0
        var found: Bool = false
        var idx = buf.size - 1
        while (idx >= 0) {
            let n = buf[idx]
            if (found && n < m) {
                break
            }
            since += 1
            if (n == m) {
                found = true
            }
            idx -= 1
        }
        return Float64(since - 1)
    })
}

