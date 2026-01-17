package indicator4cj.helper

/**
 * since 距离上次值变化的步数
 *
 * 返回每个元素距离上次值变化经过的步数。
 * 当值发生变化时，计数重置为 0；否则计数递增。
 *
 * 示例：since([5, 5, 5, 3, 3, 7]) => [0, 1, 2, 0, 1, 0]
 * 解释：
 * - 第1个 5: 首次出现，计数 0
 * - 第2个 5: 与前值相同，计数 1
 * - 第3个 5: 与前值相同，计数 2
 * - 第1个 3: 值变化，计数重置为 0
 * - 第2个 3: 与前值相同，计数 1
 * - 第1个 7: 值变化，计数重置为 0
 *
 * @param iter 数值迭代器
 * @return 步数迭代器
 */
public func since(iter: Iterator<Float64>): Iterator<Int64> {
    return SinceIterator(iter)
}

/**
 * SinceIterator 步数迭代器
 *
 * 内部实现类，跟踪距离上次值变化的步数。
 */
public class SinceIterator <: Iterator<Int64> {
    private let _source: Iterator<Float64>
    private var _isFirst: Bool = true
    private var _lastValue: Float64 = 0.0
    private var _counter: Int64 = 0

    /**
     * init 构造步数迭代器
     *
     * @param source 源数值迭代器
     */
    public init(source: Iterator<Float64>) {
        this._source = source
    }

    /**
     * next 获取下一个步数值
     *
     * @return Some(步数) 或 None（迭代结束时）
     */
    public func next(): Option<Int64> {
        match (_source.next()) {
            case Some(v) =>
                if (_isFirst || v != _lastValue) {
                    _isFirst = false
                    _lastValue = v
                    _counter = 0
                } else {
                    _counter += 1
                }
                return Some(_counter)
            case None => return None
        }
    }
}

