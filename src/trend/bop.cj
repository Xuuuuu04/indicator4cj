package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Balance of Power (BoP) = (Close - Open) / (High - Low)
public class Bop {
    public Bop() {}

    // compute 计算动能平衡指标。
    public func compute(opening: Iterator<Float64>, high: Iterator<Float64>, low: Iterator<Float64>, closing: Iterator<Float64>): Iterator<Float64> {
        return Divide(Subtract(closing, opening), Subtract(high, low))
    }
}

