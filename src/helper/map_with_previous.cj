package indicator4cj.helper

// mapWithPrevious：带前一结果的累积映射，f(prev, curr) -> next。
public func mapWithPrevious<TFrom, TTo>(iter: Iterator<TFrom>, f: (TTo, TFrom) -> TTo, previous: TTo): Iterator<TTo> {
    return MapWithPreviousIterator<TFrom, TTo>(iter, f, previous)
}

public class MapWithPreviousIterator<TFrom, TTo> <: Iterator<TTo> {
    private let _source: Iterator<TFrom>
    private let _f: (TTo, TFrom) -> TTo
    private var _prev: TTo
    private var _done: Bool = false

    public init(source: Iterator<TFrom>, f: (TTo, TFrom) -> TTo, previous: TTo) {
        this._source = source
        this._f = f
        this._prev = previous
    }

    public func next(): Option<TTo> {
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

