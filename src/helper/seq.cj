package indicator4cj.helper

// seq：生成等差序列，左闭右开。
public func seq(from: Float64, to: Float64, increment: Float64): Iterator<Float64> {
    return SeqIterator(from, to, increment)
}

public class SeqIterator <: Iterator<Float64> {
    private var _current: Float64
    private let _to: Float64
    private let _inc: Float64
    private var _finished: Bool = false

    public init(current: Float64, to: Float64, inc: Float64) {
        this._current = current
        this._to = to
        this._inc = inc
        if (inc == 0.0) {
            throw Exception("increment must not be zero")
        }
        if ((inc > 0.0 && current >= to) || (inc < 0.0 && current <= to)) {
            _finished = true
        }
    }

    public func next(): Option<Float64> {
        if (_finished) {
            return None
        }
        let v = _current
        _current = _current + _inc
        if ((_inc > 0.0 && _current >= _to) || (_inc < 0.0 && _current <= _to)) {
            _finished = true
        }
        return Some(v)
    }
}

