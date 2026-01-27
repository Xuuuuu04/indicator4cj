package indicator4cj.helper

import std.math.*

// roundDigit：按小数位四舍五入。
public func rounddigit(n: Float64, d: Int64): Float64 {
    let m = pow(10.0, Float64(d))
    let r = round(n * m) / m
    if (r == 0.0) { return 0.0 }
    return r
}

