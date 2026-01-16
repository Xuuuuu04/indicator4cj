package indicator4cj.helper

// Add：逐元素相加。
public func Add(a: Iterator<Float64>, b: Iterator<Float64>): Iterator<Float64> {
    return Operate(a, b, { x, y => x + y })
}

