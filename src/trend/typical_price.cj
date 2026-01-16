package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// Typical Price = (High + Low + Close) / 3
public class TypicalPrice {
    public TypicalPrice() {}

// compute 计算指标。
    public func compute(high: Iterator<Float64>, low: Iterator<Float64>, close: Iterator<Float64>): Iterator<Float64> {
        return DivideBy(
            Add(
                Add(high, low),
                close
            ),
            Float64(3.0)
        )
    }
}
