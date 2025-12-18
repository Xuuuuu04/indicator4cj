package indicator4cj.helper

import std.collection.*

// Highest：窗口内最大值。
public func Highest(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return Window(iter, w, { buf, _ => maxInList(buf) })
}

private func maxInList(buf: ArrayList<Float64>): Float64 {
    var m = buf[0]
    for (i in 1..buf.size) {
        let v = buf[i]
        if (v > m) { m = v }
    }
    return m
}

