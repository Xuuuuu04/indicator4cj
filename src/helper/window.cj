package indicator4cj.helper

import std.collection.*

// window：滑动窗口聚合，窗口不足时也输出当前聚合。
public func window<TElement>(iter: Iterator<TElement>, w: Int64, f: (ArrayList<TElement>, Int64) -> TElement): Iterator<TElement> {
    return WindowIterator<TElement>(iter, w, f)
}

public class WindowIterator<TElement> <: Iterator<TElement> {
    private let _source: Iterator<TElement>
    private let _w: Int64
    private let _aggregator: (ArrayList<TElement>, Int64) -> TElement
    private let _buffer = ArrayList<TElement>()
    private var _idx: Int64 = 0

    public init(source: Iterator<TElement>, w: Int64, aggregator: (ArrayList<TElement>, Int64) -> TElement) {
        this._source = source
        this._w = w
        this._aggregator = aggregator
    }

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