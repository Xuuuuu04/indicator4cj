package indicator4cj.valuation

import std.math.*

// 现值：PV = FV / (1 + 利率) ** 年数
public func pv(fv: Float64, rate: Float64, years: Int64): Float64 {
    return fv / pow(1.0 + rate, Float64(years))
}

