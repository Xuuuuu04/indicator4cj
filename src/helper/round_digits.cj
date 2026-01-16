package indicator4cj.helper

// RoundDigits：迭代器逐元素按小数位四舍五入。
public func RoundDigits(iter: Iterator<Float64>, d: Int64): Iterator<Float64> {
    return Apply(iter, { v => RoundDigit(v, d) })
}

