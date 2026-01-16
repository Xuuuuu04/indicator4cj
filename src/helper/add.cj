package indicator4cj.helper

// add：逐元素相加。
public func add(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return operate(a, b, { x, y => x + y })
}

