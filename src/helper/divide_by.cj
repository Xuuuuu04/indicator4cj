package indicator4cj.helper

// divideBy：每个元素除以给定值。
public func divideBy(iter: Iterator<Float64>, divisor: Float64): Iterator<Float64> {
    return apply(iter, { v => v / divisor })
}

