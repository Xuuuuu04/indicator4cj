package indicator4cj.helper

import std.collection.*

// window：滑动窗口聚合，窗口不足时也输出当前聚合。
public func window<T>(iter: Iterator<T>, w: Int64, f: (ArrayList<T>, Int64) -> T): Iterator<T> {
    return WindowIterator<T>(iter, w, f)
}

public class WindowIterator<T> <: Iterator<T> {
    private let _source: Iterator<T>
    private let _w: Int64
    private let _aggregator: (ArrayList<T>, Int64) -> T
    private let _buffer = ArrayList<T>()
    private var _idx: Int64 = 0

    public init(source: Iterator<T>, w: Int64, aggregator: (ArrayList<T>, Int64) -> T) {
        this._source = source
        this._w = w
        this._aggregator = aggregator
    }

    public func next(): Option<T> {
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