package indicator4cj.helper

import std.collection.*

// Head：取前 count 个元素。
public func Head<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    let out = ArrayList<T>()
    var i: Int64 = 0
    while (i < count) {
        match (iter.next()) {
            case Some(v) => out.add(v)
            case None => break
        }
        i += 1
    }
    return out.iterator()
}

