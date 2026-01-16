package indicator4cj.helper

// Count：从 from 开始递增 1，直到 other 耗尽。
public func Count<T>(from: Int64, other: Iterator<T>): Iterator<Int64> {
    return CountIterator<T>(from, other)
}

public class CountIterator<TElement> <: Iterator<Int64> {
    private var _current: Int64
    private let _other: Iterator<TElement>
    private var _done: Bool = false

    public init(_start: Int64, other: Iterator<TElement>) {
        this._current = _start
        this._other = other
    }

    public func next(): Option<Int64> {
        if (_done) {
            return None
        }
        match (_other.next()) {
            case Some(_) =>
                let v = _current
                _current += 1
                return Some(v)
            case None =>
                _done = true
                return None
        }
    }
}

