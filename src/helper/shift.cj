package indicator4cj.helper

// Shift：向右平移 count 个位置，用 fill 填充前缀。
public func Shift<T>(iter: Iterator<T>, count: Int64, fill: T): Iterator<T> {
    return ShiftIterator<T>(iter, count, fill)
}

public class ShiftIterator<T> <: Iterator<T> {
    private let source: Iterator<T>
    private var remaining: Int64
    private let fill: T

    public init(source: Iterator<T>, count: Int64, fill: T) {
        this.source = source
        this.remaining = count
        this.fill = fill
    }

    public func next(): Option<T> {
        if (remaining > 0) {
            remaining -= 1
            return Some(fill)
        }
        return source.next()
    }
}

