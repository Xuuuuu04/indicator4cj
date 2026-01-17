package indicator4cj.helper

import std.collection.*

// echo：输出原序列后，重复末尾 last 个元素共 count 轮。
// 若 last<=0 或 count<=0，则直接返回原迭代器。
public func echo<TElement>(iter: Iterator<TElement>, last: Int64, count: Int64): Iterator<TElement> {
    if (last <= 0 || count <= 0) {
        return iter
    }
    return EchoIterator<TElement>(iter, last, count)
}

public class EchoIterator<TElement> <: Iterator<TElement> {
    private let _source: Iterator<TElement>
    private let _window: Int64
    private var _remainingRounds: Int64
    private let _buf: ArrayList<TElement>
    private var _reading: Bool = true
    private var _replayIndex: Int64 = 0

    public init(source: Iterator<TElement>, last: Int64, count: Int64) {
        this._source = source
        this._window = last
        this._remainingRounds = count
        this._buf = ArrayList<TElement>()
    }

    public func next(): Option<TElement> {
        if (_reading) {
            match (_source.next()) {
                case Some(v) =>
                    if (_buf.size == _window) {
                        _buf.remove(at: 0)
                    }
                    _buf.add(v)
                    return Some(v)
                case None =>
                    _reading = false
                    if (_buf.isEmpty() || _remainingRounds <= 0) {
                        return None
                    }
            }
        }

        if (_remainingRounds <= 0 || _buf.isEmpty()) {
            return None
        }

        let idx = _replayIndex % _buf.size
        let v = _buf[Int64(idx)]
        _replayIndex += 1
        if (_replayIndex % _buf.size == 0) {
            _remainingRounds -= 1
        }
        return Some(v)
    }
}

