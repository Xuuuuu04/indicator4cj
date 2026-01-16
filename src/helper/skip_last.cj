package indicator4cj.helper

import std.collection.*

// SkipLast：丢弃末尾 count 个元素。
public func SkipLast<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    return SkipLastIterator<T>(iter, count)
}

public class SkipLastIterator<T> <: Iterator<T> {
    private let _source: Iterator<T>
    private let _tail: Int64
    private let _buffer = ArrayList<T>()

    public init(source: Iterator<T>, tail: Int64) {
        this._source = source
        this._tail = tail
    }

    public func next(): Option<T> {
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

