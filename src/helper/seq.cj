package indicator4cj.helper

// Seq：生成等差序列，左闭右开。
public func Seq(from: Float64, to: Float64, increment: Float64): Iterator<Float64> {
    return SeqIterator(from, to, increment)
}

public class SeqIterator <: Iterator<Float64> {
    private var current: Float64
    private let to: Float64
    private let inc: Float64
    private var finished: Bool = false

    public init(current: Float64, to: Float64, inc: Float64) {
        this.current = current
        this.to = to
        this.inc = inc
        if (inc == 0.0) {
            throw Exception("increment must not be zero")
        }
        if ((inc > 0.0 && current >= to) || (inc < 0.0 && current <= to)) {
            finished = true
        }
    }

    public func next(): Option<Float64> {
        if (finished) {
            return None
        }
        let v = current
        current = current + inc
        if ((inc > 0.0 && current >= to) || (inc < 0.0 && current <= to)) {
            finished = true
        }
        return Some(v)
    }
}

