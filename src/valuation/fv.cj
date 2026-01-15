package indicator4cj.valuation

import std.math.*

// Future Value: FV = PV * (1 + rate) ** years
public func fv(pv: Float64, rate: Float64, years: Int64): Float64 {
    return pv * pow(1.0 + rate, Float64(years))
}

