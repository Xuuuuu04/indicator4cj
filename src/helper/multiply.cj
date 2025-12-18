package indicator4cj.helper

// Multiply：逐元素相乘。
public func Multiply(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return Operate(a, b, { x, y => x * y })
}

