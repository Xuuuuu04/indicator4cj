package indicator4cj.helper

import std.collection.*

/**
 * chanToSlice 将迭代器消费为ArrayList
 *
 * 将Iterator中的所有元素读取并存储到ArrayList中。
 * 此操作会消费整个迭代器，迭代器使用后将不可用。
 *
 * @param iter 输入迭代器
 * @return 包含所有元素的ArrayList
 */
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


