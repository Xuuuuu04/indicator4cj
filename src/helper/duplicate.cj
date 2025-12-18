package indicator4cj.helper

import std.collection.*

// Duplicate：复制迭代器输出为 count 份独立迭代器。
public func Duplicate<T>(iter: Iterator<T>, count: Int64): ArrayList<Iterator<T>> {
    let cache = ArrayList<T>()
    while (true) {
        match (iter.next()) {
            case Some(v) => cache.add(v)
            case None => break
        }
    }
    let result = ArrayList<Iterator<T>>()
    var i: Int64 = 0
    while (i < count) {
        result.add(cache.iterator())
        i += 1
    }
    return result
}

