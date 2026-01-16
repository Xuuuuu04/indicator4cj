package indicator4cj.helper

// DivideBy：每个元素除以给定值。
public func DivideBy(iter: Iterator<Float64>, divisor: Float64): Iterator<Float64> {
    return Apply(iter, { v => v / divisor })
}

