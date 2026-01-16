package indicator4cj.helper

import std.math.*

// abs：取绝对值。
public func abs(iter: Iterator<Float64>): Iterator<Float64> {
    return apply(iter, { v => abs(v) })
}

