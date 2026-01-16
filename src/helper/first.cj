package indicator4cj.helper

import std.collection.*

// first：取前 count 个元素，并消费余下元素（与 Go 版 Drain 行为一致）。
public func first<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    let out = ArrayList<T>()
    var i: Int64 = 0
    while (i < count) {
        match (iter.next()) {
            case Some(v) => out.add(v)
            case None => break
        }
        i += 1
    }
    // drain 余下元素
    drain(iter)
    return out.iterator()
}

