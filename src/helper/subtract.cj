package indicator4cj.helper

// subtract：逐元素相减（a - b）。
public func subtract(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return operate(a, b, { x, y => x - y })
}

