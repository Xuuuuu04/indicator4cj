package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// RSI：100 - 100 / (1 + RS)，RS = 周期内平均涨幅/平均跌幅。
public class Rsi {
    // 周期
    public var period: Int64 = 14
    private let _rma: Rma

    public Rsi() {
        this._rma = Rma(this.period)
    }

    public init(period: Int64) {
        this.period = period
        this._rma = Rma(period)
    }

    // compute 计算相对强弱指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let changes = change(values, 1)
        let dup = duplicate(changes, 2)
        let avgGain = _rma.compute(keepPositives(dup[0]))
        let avgLoss = multiplyBy(_rma.compute(keepNegatives(dup[1])), -1.0)
        let rs = divide(avgGain, avgLoss)
        // RSI = 100 - 100 / (1 + RS)
        let rsi = incrementBy(multiplyBy(multiplyBy(pow(incrementBy(rs, 1.0), -1.0), 100.0), -1.0), 100.0)
        return rsi
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _rma.idlePeriod() + 1 }
}

