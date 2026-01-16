package indicator4cj.helper

// roundDigits：迭代器逐元素按小数位四舍五入。
public func roundDigits(iter: Iterator<Float64>, d: Int64): Iterator<Float64> {
    return apply(iter, { v => rounddigit(v, d) })
}

