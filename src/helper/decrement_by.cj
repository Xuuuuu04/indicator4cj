package indicator4cj.helper

// decrementBy：每个元素减去给定值。
public func decrementBy(iter: Iterator<Float64>, dec: Float64): Iterator<Float64> {
    return apply(iter, { v => v - dec })
}

