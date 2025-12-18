package indicator4cj.helper

// IncrementBy：每个元素加上给定增量。
public func IncrementBy(iter: Iterator<Float64>, inc: Float64): Iterator<Float64> {
    return Apply(iter, { v => v + inc })
}

