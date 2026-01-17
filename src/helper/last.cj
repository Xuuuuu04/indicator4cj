package indicator4cj.helper

import std.collection.*

/**
 * last 返回末尾 count 个元素
 *
 * 使用环形缓冲区缓存最后 count 个元素。
 * 如果迭代器元素总数少于 count，返回所有元素。
 *
 * 示例：
 * - last([1, 2, 3, 4, 5], 3) => [3, 4, 5]
 * - last([1, 2], 5) => [1, 2]
 *
 * @param iter 源迭代器
 * @param count 要获取的末尾元素数量
 * @return 包含末尾 count 个元素的迭代器
 */
public func last<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    let ring = Ring<T>(count)
    var filled: Int64 = 0
    while (true) {
        match (iter.next()) {
            case Some(v) =>
                ring.put(v)
                if (filled < count) {
                    filled += 1
                }
            case None => break
        }
    }
    let out = ArrayList<T>()
    var i: Int64 = 0
    while (i < filled) {
        match (ring.get()) {
            case Some(v) => out.add(v)
            case None => ()
        }
        i += 1
    }
    return out.iterator()
}

