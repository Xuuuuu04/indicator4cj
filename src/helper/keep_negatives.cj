package indicator4cj.helper

// KeepNegatives：负数保留，非负置零。
public func KeepNegatives(iter: Iterator<Float64>): Iterator<Float64> {
    return Apply(iter, { v =>
        if (v < 0.0) { return v }
        return 0.0
    })
}

