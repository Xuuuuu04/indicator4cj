package indicator4cj.helper

/**
 * filterIter 按谓词过滤迭代器元素（内部API）
 *
 * 创建一个迭代器，只保留满足谓词条件的元素。
 *
 * @param iter 输入迭代器
 * @param predicate 谓词函数，返回true表示保留该元素
 * @return 过滤后的迭代器
 */
public func filterIter<TElement>(iter: Iterator<TElement>, predicate: (TElement) -> Bool): Iterator<TElement> {
    return FilterIterator<TElement>(iter, predicate)
}

/**
 * filter 按谓词过滤迭代器元素
 *
 * 创建一个迭代器，只保留满足谓词条件的元素。
 * 这是一个惰性求值函数，在迭代时按需过滤。
 *
 * ### 示例
 * ```cangjie
 * let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
 * let evens = filter(numbers.iterator(), func(x: Int64): Bool { x % 2 == 0 })
 * // 结果: [2, 4, 6, 8, 10]
 *
 * let words = ["apple", "", "banana", "", "cherry"]
 * let nonEmpty = filter(words.iterator(), func(s: String): Bool { s.size > 0 })
 * // 结果: ["apple", "banana", "cherry"]
 * ```
 *
 * @param iter 输入迭代器
 * @param predicate 谓词函数，返回true表示保留该元素
 * @return 过滤后的迭代器
 */
public func filter<TElement>(iter: Iterator<TElement>, predicate: (TElement) -> Bool): Iterator<TElement> {
    return filterIter(iter, predicate)
}

/**
 * FilterIterator 过滤迭代器实现
 *
 * 内部迭代器类，实现元素过滤的具体逻辑。
 *
 * @param TElement 元素类型
 */
public class FilterIterator<TElement> <: Iterator<TElement> {
    /**
     * _source 源迭代器
     */
    private let _source: Iterator<TElement>

    /**
     * _predicate 谓词函数
     *
     * 返回true表示保留该元素
     */
    private let _predicate: (TElement) -> Bool

    /**
     * 构造函数
     *
     * @param source 源迭代器
     * @param predicate 谓词函数
     */
    public init(source: Iterator<TElement>, predicate: (TElement) -> Bool) {
        this._source = source
        this._predicate = predicate
    }

    /**
     * next 返回下一个满足条件的元素
     *
     * 跳过不满足谓词的元素，直到找到满足条件的元素或到达迭代器末尾。
     *
     * @return 满足条件的元素的Option，没有更多元素时返回None
     */
    public func next(): Option<TElement> {
        while (true) {
            match (_source.next()) {
                case Some(v) =>
                    if (_predicate(v)) {
                        return Some(v)
                    }
                case None => return None
            }
        }
        return None
    }
}
