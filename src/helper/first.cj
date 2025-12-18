package indicator4cj.helper

import std.collection.*

// First：取前 count 个元素，并消费余下元素（与 Go 版 Drain 行为一致）。
public func First<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    let out = ArrayList<T>()
    var i: Int64 = 0
    while (i < count) {
        match (iter.next()) {
            case Some(v) => out.add(v)
            case None => break
        }
        i += 1
    }
    // Drain 余下元素
    Drain(iter)
    return out.iterator()
}

