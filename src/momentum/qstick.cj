package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// QStick = SMA(周期, 收盘价 - 开盘价)
public class Qstick {
    // 周期
    public var period: Int64 = 20

    public Qstick() {
        // 使用默认值 20
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算QStick指标。
    public func compute(opens: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        let diff = subtract(closes, opens)
        let sma = Sma()
        sma.period = period
        return sma.compute(diff)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

