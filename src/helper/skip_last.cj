package indicator4cj.helper

import std.collection.*

// skipLast：丢弃末尾 count 个元素。
public func skipLast<TElement>(iter: Iterator<TElement>, count: Int64): Iterator<TElement> {
    return SkipLastIterator<TElement>(iter, count)
}

public class SkipLastIterator<TElement> <: Iterator<TElement> {
    private let _source: Iterator<TElement>
    private let _tail: Int64
    private let _buffer = ArrayList<TElement>()

    public init(source: Iterator<TElement>, tail: Int64) {
        this._source = source
        this._tail = tail
    }

    public func next(): Option<TElement> {
        while (_buffer.size <= _tail) {
            match (_source.next()) {
                case Some(v) => _buffer.add(v)
                case None => return None
            }
        }
        let out = _buffer[0]
        _buffer.remove(at: 0)
        return Some(out)
    }
}

