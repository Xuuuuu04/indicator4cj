package indicator4cj.helper

// KeepPositives：正数保留，非正置零。
public func KeepPositives(iter: Iterator<Float64>): Iterator<Float64> {
    return Apply(iter, { v =>
        if (v > 0.0) { return v }
        return 0.0
    })
}

