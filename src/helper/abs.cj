package indicator4cj.helper

import std.math.*

// Abs：取绝对值。
public func Abs(iter: Iterator<Float64>): Iterator<Float64> {
    return Apply(iter, { v => abs(v) })
}

