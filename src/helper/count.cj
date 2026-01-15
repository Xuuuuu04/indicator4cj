package indicator4cj.helper

// Count：从 from 开始递增 1，直到 other 耗尽。
public func Count<T>(from: Int64, other: Iterator<T>): Iterator<Int64> {
    return CountIterator<T>(from, other)
}

public class CountIterator<T> <: Iterator<Int64> {
    private var current: Int64
    private let other: Iterator<T>
    private var done: Bool = false

    public init(_start: Int64, other: Iterator<T>) {
        this.current = _start
        this.other = other
    }

    public func next(): Option<Int64> {
        if (done) {
            return None
        }
        match (other.next()) {
            case Some(_) =>
                let v = current
                current += 1
                return Some(v)
            case None =>
                done = true
                return None
        }
    }
}

