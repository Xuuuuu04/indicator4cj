package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// QStick = SMA(period, Close - Open)
public class Qstick {
    public var period: Int64 = 20

    public Qstick() { this.period = period }
    public init(period: Int64) { this.period = period }

    public func compute(opens: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        let diff = Subtract(closes, opens)
        let sma = Sma()
        sma.period = this.period
        return sma.compute(diff)
    }

    public func idlePeriod(): Int64 { return this.period - 1 }
}

