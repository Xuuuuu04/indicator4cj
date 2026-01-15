package indicator4cj.helper

import std.collection.*

// SkipLast：丢弃末尾 count 个元素。
public func SkipLast<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    return SkipLastIterator<T>(iter, count)
}

public class SkipLastIterator<T> <: Iterator<T> {
    private let source: Iterator<T>
    private let tail: Int64
    private let buffer = ArrayList<T>()

    public init(source: Iterator<T>, tail: Int64) {
        this.source = source
        this.tail = tail
    }

    public func next(): Option<T> {
        while (buffer.size <= tail) {
            match (source.next()) {
                case Some(v) => buffer.add(v)
                case None => return None
            }
        }
        let out = buffer[0]
        buffer.remove(at: 0)
        return Some(out)
    }
}

