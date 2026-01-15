package indicator4cj.valuation

import std.math.*

// Present Value: PV = FV / (1 + rate) ** years
public func pv(fv: Float64, rate: Float64, years: Int64): Float64 {
    return fv / pow(1.0 + rate, Float64(years))
}

