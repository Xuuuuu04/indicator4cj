package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// RSI: 100 - 100 / (1 + RS), RS = AvgGain/AvgLoss over period.
public class Rsi {
    // 周期
    public var period: Int64 = 14
    private let rma: Rma

    public Rsi() {
        this.rma = Rma(this.period)
    }

    public init(period: Int64) {
        this.period = period
        this.rma = Rma(period)
    }

    // compute 计算相对强弱指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let changes = Change(values, 1)
        let dup = Duplicate(changes, 2)
        let avgGain = rma.compute(KeepPositives(dup[0]))
        let avgLoss = MultiplyBy(rma.compute(KeepNegatives(dup[1])), -1.0)
        let rs = Divide(avgGain, avgLoss)
        // RSI = 100 - 100 / (1 + RS)
        let rsi = IncrementBy(MultiplyBy(MultiplyBy(Pow(IncrementBy(rs, 1.0), -1.0), 100.0), -1.0), 100.0)
        return rsi
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return rma.idlePeriod() + 1 }
}

