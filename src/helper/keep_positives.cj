package indicator4cj.helper

// keepPositives：正数保留，非正置零。
public func keepPositives(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v =>
        if (v > 0.0) { return v }
        return 0.0
    })
}

