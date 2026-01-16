package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// 加权收盘价 = (最高价 + 最低价 + (收盘价 * 2)) / 4
public class WeightedClose {
    public WeightedClose() {
    }

// compute 计算指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>): Iterator<Float64> {
        return Operate3(highs, lows, closes, { h: Float64, l: Float64, c: Float64 =>
            return (h + l + (c * 2.0)) / 4.0
        })
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 0 }

// toString 返回指标的字符串表示。
    public func toString(): String { return "Weighted Close" }
}
