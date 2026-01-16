package indicator4cj.helper

import std.math.*

// Sqrt：对迭代器每个元素开平方。
public func Sqrt(iter: Iterator<Float64>): Iterator<Float64> {
    return Apply(iter, { v => sqrt(v) })
}

