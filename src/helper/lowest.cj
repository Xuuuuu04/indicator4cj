package indicator4cj.helper

import std.collection.*

// lowest：窗口内最小值。
public func lowest(iter: Iterator<Float64>, w: Int64): Iterator<Float64> {
    return window(iter, w, { buf, _ => minInList(buf) })
}

private func minInList(buf: ArrayList<Float64>): Float64 {
    var m = buf[0]
    for (i in 1..buf.size) {
        let v = buf[i]
        if (v < m) { m = v }
    }
    return m
}

