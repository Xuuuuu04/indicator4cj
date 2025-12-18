package indicator4cj.helper

// DecrementBy：每个元素减去给定值。
public func DecrementBy(iter: Iterator<Float64>, dec: Float64): Iterator<Float64> {
    return Apply(iter, { v => v - dec })
}

