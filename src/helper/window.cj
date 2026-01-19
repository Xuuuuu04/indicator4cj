package indicator4cj.helper

import std.collection.*

/**
 * window 滑动窗口聚合
 *
 * 对迭代器元素应用滑动窗口聚合函数。
 * 即使窗口未填满，也会输出当前聚合结果。
 *
 * ### 特性
 * - 惰性求值：只在调用next()时处理元素
 * - 动态窗口：窗口不足时也输出当前聚合
 * - 灵活聚合：支持自定义聚合函数
 *
 * ### 适用场景
 * - 计算移动平均线
 * - 滑动窗口统计（如最大值、最小值）
 * - 时间序列平滑处理
 *
 * ### 示例
 * ```cangjie
 * let data = [1.0, 2.0, 3.0, 4.0, 5.0]
 * let avg = window(data.iterator(), 3, { buf, start =>
 *     var sum = 0.0
 *     for (x in buf) { sum += x }
 *     sum / buf.size
 * })
 * // 结果: [1.0, 1.5, 2.0, 3.0, 4.0]
 * ```
 *
 * @param TElement 元素类型
 * @param iter 输入迭代器
 * @param w 窗口大小
 * @param f 聚合函数，接收窗口缓冲区和起始索引
 * @return 聚合结果迭代器
 */
public func window<TElement>(iter: Iterator<TElement>, w: Int64, f: (ArrayList<TElement>, Int64) -> TElement): Iterator<TElement> {
    return WindowIterator<TElement>(iter, w, f)
}

/**
 * WindowIterator 滑动窗口迭代器实现
 *
 * 内部迭代器类，实现滑动窗口聚合的具体逻辑。
 * 维护一个固定大小的缓冲区，每次有新元素时更新窗口。
 *
 * @param TElement 元素类型
 */
public class WindowIterator<TElement> <: Iterator<TElement> {
    private let _source: Iterator<TElement>
    private let _w: Int64
    private let _aggregator: (ArrayList<TElement>, Int64) -> TElement
    private let _buffer = ArrayList<TElement>()
    private var _idx: Int64 = 0

    /**
     * 构造函数
     *
     * @param source 源迭代器
     * @param w 窗口大小
     * @param aggregator 聚合函数
     */
    public init(source: Iterator<TElement>, w: Int64, aggregator: (ArrayList<TElement>, Int64) -> TElement) {
        this._source = source
        this._w = w
        this._aggregator = aggregator
    }

    /**
     * next 返回下一个聚合值
     *
     * 从源迭代器获取下一个元素，更新窗口并应用聚合函数。
     *
     * @return 聚合值的Option，源迭代器结束时返回None
     */
    public func next(): Option<TElement> {
        match (_source.next()) {
            case Some(v) =>
                if (_buffer.size == _w) {
                    _buffer.remove(at: 0)
                }
                _buffer.add(v)
                let start = _idx % _w
                _idx += 1
                return Some(_aggregator(_buffer, start))
            case None => return None
        }
    }
}