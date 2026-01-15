package indicator4cj.helper

// Since：距离上次值变化的步数。
public func Since(iter: Iterator<Float64>): Iterator<Int64> {
    return SinceIterator(iter)
}

public class SinceIterator <: Iterator<Int64> {
    private let source: Iterator<Float64>
    private var isFirst: Bool = true
    private var lastValue: Float64 = 0.0
    private var counter: Int64 = 0

    public init(source: Iterator<Float64>) {
        this.source = source
    }

    public func next(): Option<Int64> {
        match (source.next()) {
            case Some(v) =>
                if (isFirst || v != lastValue) {
                    isFirst = false
                    lastValue = v
                    counter = 0
                } else {
                    counter += 1
                }
                return Some(counter)
            case None => return None
        }
    }
}

