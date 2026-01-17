package indicator4cj.helper

/**
 * count 生成计数序列
 *
 * 从 from 开始递增生成计数序列，长度与 other 迭代器相同。
 * 当 other 耗尽时，计数也停止。
 *
 * 示例：count(from: 1, other: [10, 20, 30]) => [1, 2, 3]
 *
 * @param from 起始计数值
 * @param other 参考迭代器，决定计数序列长度
 * @return 计数迭代器
 */
public func count<T>(from: Int64, other: Iterator<T>): Iterator<Int64> {
    return CountIterator<T>(from, other)
}

/**
 * CountIterator 计数迭代器
 *
 * 内部实现类，生成从起始值开始的递增序列。
 * 序列长度与参考迭代器相同。
 */
public class CountIterator<TElement> <: Iterator<Int64> {
    private var _current: Int64
    private let _other: Iterator<TElement>
    private var _done: Bool = false

    /**
     * init 构造计数迭代器
     *
     * @param _start 起始计数值
     * @param other 参考迭代器
     */
    public init(_start: Int64, other: Iterator<TElement>) {
        this._current = _start
        this._other = other
    }

    /**
     * next 获取下一个计数值
     *
     * @return Some(计数值) 或 None（参考迭代器结束时）
     */
    public func next(): Option<Int64> {
        if (_done) {
            return None
        }
        match (_other.next()) {
            case Some(_) =>
                let v = _current
                _current += 1
                return Some(v)
            case None =>
                _done = true
                return None
        }
    }
}

