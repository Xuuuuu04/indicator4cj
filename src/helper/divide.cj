package indicator4cj.helper

// Divide：逐元素相除（a / b）。
public func Divide(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return Operate(a, b, { x, y => x / y })
}

