package indicator4cj.helper

// multiplyBy：每个元素乘以给定倍数。
public func multiplyBy(iter: Iterator<Float64>, factor: Float64): Iterator<Float64> {
    return apply(iter, { v => v * factor })
}

