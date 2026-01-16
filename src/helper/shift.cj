package indicator4cj.helper

// Shift：向右平移 count 个位置，用 fill 填充前缀。
public func Shift<T>(iter: Iterator<T>, count: Int64, fill: T): Iterator<T> {
    return ShiftIterator<T>(iter, count, fill)
}

public class ShiftIterator<T> <: Iterator<T> {
    private let _source: Iterator<T>
    private var _remaining: Int64
    private let _fill: T

    public init(source: Iterator<T>, count: Int64, fill: T) {
        this._source = source
        this._remaining = count
        this._fill = fill
    }

    public func next(): Option<T> {
        if (_remaining > 0) {
            _remaining -= 1
            return Some(_fill)
        }
        return _source.next()
    }
}

