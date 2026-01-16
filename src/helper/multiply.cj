package indicator4cj.helper

// multiply：逐元素相乘。
public func multiply(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return operate(a, b, { x, y => x * y })
}

