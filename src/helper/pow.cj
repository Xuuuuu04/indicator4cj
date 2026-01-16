package indicator4cj.helper

import std.math.*

// pow：对迭代器每个元素做幂运算。
public func pow(iter: Iterator<Float64>, exp: Float64): Iterator<Float64> {
    return apply(iter, { v => pow(v, exp) })
}

