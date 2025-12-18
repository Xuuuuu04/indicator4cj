package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// QStick = SMA(period, Close - Open)
public class Qstick {
    public var Period: Int64

    public init() { this.Period = 20 }
    public init(period: Int64) { this.Period = period }

    public func Compute(opens: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        let diff = Subtract(closes, opens)
        let sma = Sma()
        sma.Period = Period
        return sma.Compute(diff)
    }

    public func IdlePeriod(): Int64 { return Period - 1 }
}

public func NewQstick(): Qstick {
    return Qstick()
}

