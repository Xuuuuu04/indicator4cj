package indicator4cj.valuation

import std.math.*

// 终值：FV = PV * (1 + 利率) ** 年数
public func fv(pv: Float64, rate: Float64, years: Int64): Float64 {
    return pv * pow(1.0 + rate, Float64(years))
}

