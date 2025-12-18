package indicator4cj.helper

// Sign：返回符号，负数 -1，零 0，正数 1。
public func Sign(iter: Iterator<Float64>): Iterator<Float64> {
    return Apply(iter, { v =>
        if (v > 0.0) {
            return 1.0
        } else if (v < 0.0) {
            return -1.0
        }
        return 0.0
    })
}

