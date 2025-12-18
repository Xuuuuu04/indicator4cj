package indicator4cj.helper

// MultiplyBy：每个元素乘以给定倍数。
public func MultiplyBy(iter: Iterator<Float64>, factor: Float64): Iterator<Float64> {
    return Apply(iter, { v => v * factor })
}

