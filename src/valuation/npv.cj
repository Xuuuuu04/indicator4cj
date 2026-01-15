package indicator4cj.valuation

import std.math.*
import std.collection.*

// Net Present Value: sum(cashflow_i / (1+rate) ** (i+1))
public func npv(rate: Float64, cashFlows: ArrayList<Float64>): Float64 {
    var acc = 0.0
    var idx: Int64 = 0
    while (idx < cashFlows.size) {
        let cf = cashFlows[idx]
        acc = acc + cf / pow(1.0 + rate, Float64(idx + 1))
        idx = idx + 1
    }
    return acc
}

