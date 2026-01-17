package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// 威廉姆斯百分比R = -100 * (N周期最高价 - 收盘价) / (N周期最高价 - N周期最低价)
public class WilliamsR {
    // 周期
    public var period: Int64 = 14

    public WilliamsR() {
        // 使用默认值 14
    }

    public init(period: Int64) {
        this.period = period
    }

    // compute 计算威廉姆斯百分比R指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        let hh = MovingMax(period).compute(highs)
        let ll = MovingMin(period).compute(lows)

        let closesAdj = skip(closes, period - 1)

        return operate3(hh, ll, closesAdj, { h: Float64, l: Float64, c: Float64 =>
            let denom = h - l
            if (denom == 0.0) { return 0.0 }
            return -100.0 * (h - c) / denom
        })
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

