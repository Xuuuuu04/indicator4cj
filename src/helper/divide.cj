package indicator4cj.helper

// divide：逐元素相除（a / b）。
public func divide(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return operate(a, b, { x, y => x / y })
}

