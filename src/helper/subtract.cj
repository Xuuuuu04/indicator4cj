package indicator4cj.helper

// Subtract：逐元素相减（a - b）。
public func Subtract(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return Operate(a, b, { x, y => x - y })
}

