package indicator4cj.helper

// keepNegatives：负数保留，非负置零。
public func keepNegatives(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v =>
        if (v < 0.0) { return v }
        return 0.0
    })
}

