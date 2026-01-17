package indicator4cj.helper

import std.collection.*

/**
 * minSince 自最近最小值以来的步数
 *
 * 返回每个元素自最近最小值起经过的步数（含自身）。
 * 使用滑动窗口，窗口大小为 w。
 *
 * 计算逻辑：
 * 1. 在窗口内查找最小值
 * 2. 从当前元素向前回溯，计算距离最近最小值的步数
 * 3. 如果当前元素就是最小值，返回 0
 *
 * 示例：minSince([5, 3, 4, 2, 3], 3) => [0, 0, 1, 0, 1]
 * 解释：
 * - 5: 窗口 [5]，最小值 5，距离 0
 * - 3: 窗口 [5,3]，最小值 3，距离 0
 * - 4: 窗口 [5,3,4]，最小值 3，距离 1
 * - 2: 窗口 [3,4,2]，最小值 2，距离 0
 * - 3: 窗口 [4,2,3]，最小值 2，距离 1
 *
 * @param iter 数值迭代器
 * @param w 滑动窗口大小
 * @return 步数迭代器
 */
public func minSince(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return window<Float64>(iter, w, { buf, _ =>
        if (buf.isEmpty()) {
            return Float64(0)
        }
        var m = buf[0]
        for (i in 1..buf.size) {
            let v = buf[i]
            if (v < m) {
                m = v
            }
        }

        var since: Int64 = 0
        var found: Bool = false
        var idx = buf.size - 1
        while (idx >= 0) {
            let n = buf[idx]
            if (found && n > m) {
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

