package indicator4cj.helper

// MapWithPrevious：带前一结果的累积映射，f(prev, curr) -> next。
public func MapWithPrevious<F, T>(iter: Iterator<F>, f: (T, F) -> T, previous: T): Iterator<T> {
    return MapWithPreviousIterator<F, T>(iter, f, previous)
}

public class MapWithPreviousIterator<F, T> <: Iterator<T> {
    private let source: Iterator<F>
    private let f: (T, F) -> T
    private var prev: T
    private var done: Bool = false

    public init(source: Iterator<F>, f: (T, F) -> T, previous: T) {
        this.source = source
        this.f = f
        this.prev = previous
    }

    public func next(): Option<T> {
        if (done) {
            return None
        }
        match (source.next()) {
            case Some(n) =>
                prev = f(prev, n)
                return Some(prev)
            case None =>
                done = true
                return None
        }
    }
}

