package indicator4cj.helper

import std.collection.*

// Last：返回末尾 count 个元素。
public func Last<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    let ring = Ring<T>(count)
    var filled: Int64 = 0
    while (true) {
        match (iter.next()) {
            case Some(v) =>
                ring.Put(v)
                if (filled < count) {
                    filled += 1
                }
            case None => break
        }
    }
    let out = ArrayList<T>()
    var i: Int64 = 0
    while (i < filled) {
        match (ring.Get()) {
            case Some(v) => out.add(v)
            case None => ()
        }
        i += 1
    }
    return out.iterator()
}

