package indicator4cj.helper

// since：距离上次值变化的步数。
public func since(iter: Iterator<Float64>): Iterator<Int64> {
    return SinceIterator(iter)
}

public class SinceIterator <: Iterator<Int64> {
    private let _source: Iterator<Float64>
    private var _isFirst: Bool = true
    private var _lastValue: Float64 = 0.0
    private var _counter: Int64 = 0

    public init(source: Iterator<Float64>) {
        this._source = source
    }

    public func next(): Option<Int64> {
        match (_source.next()) {
            case Some(v) =>
                if (_isFirst || v != _lastValue) {
                    _isFirst = false
                    _lastValue = v
                    _counter = 0
                } else {
                    _counter += 1
                }
                return Some(_counter)
            case None => return None
        }
    }
}

