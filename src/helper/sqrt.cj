package indicator4cj.helper

import std.math.*

// sqrt：对迭代器每个元素开平方。
public func sqrt(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v => sqrt(v) })
}

