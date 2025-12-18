package indicator4cj.helper

import std.collection.*

// MinSince：返回每个元素自最近最小值起经过的步数（含自身），窗口大小 w。
public func MinSince(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return Window<Float64>(iter, w, { buf, _ =>
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

