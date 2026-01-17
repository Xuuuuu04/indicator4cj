package indicator4cj.helper

import std.collection.*

/**
 * duplicate 复制迭代器
 *
 * 将迭代器输出复制为 count 份独立迭代器。
 * 通过缓存所有元素实现，适用于小数据集。
 *
 * 注意：会完全消费原迭代器并缓存所有元素。
 *
 * 示例：
 * let dup = duplicate([1, 2, 3], 2)
 * dup[0] => [1, 2, 3]
 * dup[1] => [1, 2, 3]
 *
 * @param iter 源迭代器
 * @param count 复制份数
 * @return 包含 count 个独立迭代器的列表
 */
public func duplicate<TElement>(iter: Iterator<TElement>, count: Int64): ArrayList<Iterator<TElement>> {
    let cache = ArrayList<TElement>()
    while (true) {
        match (iter.next()) {
            case Some(v) => cache.add(v)
            case None => break
        }
    }
    let result = ArrayList<Iterator<TElement>>()
    var i: Int64 = 0
    while (i < count) {
        result.add(cache.iterator())
        i += 1
    }
    return result
}

