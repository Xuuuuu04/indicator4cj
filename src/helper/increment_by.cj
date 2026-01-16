package indicator4cj.helper

// incrementBy：每个元素加上给定增量。
public func incrementBy(iter: Iterator<Float64>, inc: Float64): Iterator<Float64> {
    return apply(iter, { v => v + inc })
}

