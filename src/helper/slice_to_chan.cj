package indicator4cj.helper

import std.collection.*

// sliceToChan：将 ArrayList 转为 Iterator，语义等价 Go 版 slice->channel。
public func sliceToChan<T>(list: ArrayList<T>): Iterator<T> {
    // 直接复用集合迭代器；保持只读消费语义。
    return list.iterator()
}


