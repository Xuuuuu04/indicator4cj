package indicator4cj.helper

import std.collection.*

// Change：当前值减去 before 步之前的值（长度为 n-before），与 Go 语义一致。
public func Change(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    return ChangeIterator(iter, before, { curr, prev => curr - prev })
}

public class ChangeIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _before: Int64
    private let _queue = ArrayList<Float64>()
    private let _combine: (Float64, Float64) -> Float64

    public init(source: Iterator<Float64>, before: Int64, combine: (Float64, Float64) -> Float64) {
        this._source = source
        this._before = before
        this._combine = combine
    }

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

