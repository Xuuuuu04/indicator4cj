package indicator4cj.helper

import std.math.*

// roundDigit：按小数位四舍五入。
public func rounddigit(n: Float64, d: Int64): Float64 {
    let m = pow(10.0, Float64(d))
    return round(n * m) / m
}

