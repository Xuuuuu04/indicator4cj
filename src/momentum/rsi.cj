package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// RSI: 100 - 100 / (1 + RS), RS = AvgGain/AvgLoss over period.
public class Rsi {
    public var Period: Int64
    private let _rma: Rma

    public init() {
        this.Period = 14
        this._rma = Rma(Period)
    }

    public init(period: Int64) {
        this.Period = period
        this._rma = Rma(period)
    }

    public func Compute(values: Iterator<Float64>): Iterator<Float64> {
        let changes = Change(values, 1)
        let dup = Duplicate(changes, 2)
        let avgGain = _rma.Compute(KeepPositives(dup[0]))
        let avgLoss = MultiplyBy(_rma.Compute(KeepNegatives(dup[1])), -1.0)
        let rs = Divide(avgGain, avgLoss)
        // RSI = 100 - 100 / (1 + RS)
        let rsi = IncrementBy(MultiplyBy(MultiplyBy(Pow(IncrementBy(rs, 1.0), -1.0), 100.0), -1.0), 100.0)
        return rsi
    }

    public func IdlePeriod(): Int64 { return _rma.IdlePeriod() + 1 }
}

