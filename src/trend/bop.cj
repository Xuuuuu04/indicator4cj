package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// 动能平衡指标(BoP) = (收盘价 - 开盘价) / (最高价 - 最低价)
public class Bop {
    public Bop() {
    }

    // compute 计算动能平衡指标。
    public func compute(opening: Iterator<Float64>, high: Iterator<Float64>, low: Iterator<Float64>, closing: Iterator<Float64>): Iterator<Float64> {
        return divide(subtract(closing, opening), subtract(high, low))
    }
}

