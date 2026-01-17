package indicator4cj.helper

import std.collection.*

/**
 * change 计算差值变化
 *
 * 计算当前值与 before 步之前的值的差值（当前值 - 前值）。
 * 输出迭代器长度为 n-before，与 Go 版本语义一致。
 *
 * 示例：change([1, 2, 3, 4, 5], 2) => [None, None, 2, 2, 2]
 * 解释：第3个元素 3 - 第1个元素 1 = 2
 *
 * @param iter 数值迭代器
 * @param before 回溯步数
 * @return 差值迭代器，长度为 n-before
 */
public func change(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    return ChangeIterator(iter, before, { curr, prev => curr - prev })
}

/**
 * ChangeIterator 差值计算迭代器
 *
 * 内部实现类，用于计算当前值与历史值的差值。
 * 使用队列缓存 before 个历史值。
 */
public class ChangeIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _before: Int64
    private let _queue = ArrayList<Float64>()
    private let _combine: (Float64, Float64) -> Float64

    /**
     * init 构造差值迭代器
     *
     * @param source 源数值迭代器
     * @param before 回溯步数
     * @param combine 组合函数，默认为减法
     */
    public init(source: Iterator<Float64>, before: Int64, combine: (Float64, Float64) -> Float64) {
        this._source = source
        this._before = before
        this._combine = combine
    }

    /**
     * next 获取下一个差值
     *
     * @return Some(差值) 或 None（迭代结束时）
     */
    public func next(): Option<Float64> {
        match (_source.next()) {
            case Some(v) =>
                _queue.add(v)
                if (_queue.size <= _before) {
                    return next()
                }
                let prev = _queue[0]
                _queue.remove(at: 0)
                return Some(_combine(v, prev))
            case None => return None
        }
    }
}

