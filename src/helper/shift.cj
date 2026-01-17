package indicator4cj.helper

// shift：向右平移 count 个位置，用 fill 填充前缀。
public func shift<TElement>(iter: Iterator<TElement>, count: Int64, fill: TElement): Iterator<TElement> {
    return ShiftIterator<TElement>(iter, count, fill)
}

public class ShiftIterator<TElement> <: Iterator<TElement> {
    private let _source: Iterator<TElement>
    private var _remaining: Int64
    private let _fill: TElement

    public init(source: Iterator<TElement>, count: Int64, fill: TElement) {
        this._source = source
        this._remaining = count
        this._fill = fill
    }

    public func next(): Option<TElement> {
        if (_remaining > 0) {
            _remaining -= 1
            return Some(_fill)
        }
        return _source.next()
    }
}

