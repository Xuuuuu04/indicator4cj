package indicator4cj.helper

import std.math.*

// Pow：对迭代器每个元素做幂运算。
public func Pow(iter: Iterator<Float64>, exp: Float64): Iterator<Float64> {
    return Apply(iter, { v => pow(v, exp) })
}

