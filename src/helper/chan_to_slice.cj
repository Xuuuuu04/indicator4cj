package indicator4cj.helper

import std.collection.*

// ChanToSlice：将 Iterator 消费为 ArrayList。
public func chanToSlice<T>(iter: Iterator<T>): ArrayList<T> {
    let out = ArrayList<T>()
    while (true) {
        match (iter.next()) {
            case Some(v) => out.add(v)
            case None => break
        }
    }
    return out
}

// Go 同名兼容导出。
public func ChanToSlice<T>(iter: Iterator<T>): ArrayList<T> {
    return chanToSlice(iter)
}

