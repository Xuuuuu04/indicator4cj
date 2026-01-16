package indicator4cj.helper

// sign：返回符号，负数 -1，零 0，正数 1。
public func sign(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v =>
        if (v > 0.0) {
            return 1.0
        } else if (v < 0.0) {
            return -1.0
        }
        return 0.0
    })
}

