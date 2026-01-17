package indicator4cj.helper

import std.collection.*

/**
 * head 取前 count 个元素
 *
 * 从迭代器中取前 count 个元素，不消费余下元素。
 * 与 first() 不同，此函数不会耗尽原迭代器。
 *
 * 示例：head([1, 2, 3, 4, 5], 3) => [1, 2, 3]
 *
 * @param iter 源迭代器
 * @param count 要获取的元素数量
 * @return 包含前 count 个元素的迭代器
 */
public func head<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
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

