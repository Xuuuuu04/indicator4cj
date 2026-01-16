package indicator4cj.helper

// MapWithPrevious：带前一结果的累积映射，f(prev, curr) -> next。
public func MapWithPrevious<F, T>(iter: Iterator<F>, f: (T, F) -> T, previous: T): Iterator<T> {
    return MapWithPreviousIterator<F, T>(iter, f, previous)
}

public class MapWithPreviousIterator<F, T> <: Iterator<T> {
    private let _source: Iterator<F>
    private let _f: (T, F) -> T
    private var _prev: T
    private var _done: Bool = false

    public init(source: Iterator<F>, f: (T, F) -> T, previous: T) {
        this._source = source
        this._f = f
        this._prev = previous
    }

    public func next(): Option<T> {
        if (_done) {
            return None
        }
        match (_source.next()) {
            case Some(n) =>
                _prev = _f(_prev, n)
                return Some(_prev)
            case None =>
                _done = true
                return None
        }
    }
}

