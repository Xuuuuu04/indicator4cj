package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    private let bands = BollingerBands()

    public BollingerBandWidth() {
    }

    // compute 计算布林带宽度指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let (upper, middle, lower) = bands.compute(c)
        return Divide(
            Subtract(upper, lower),
            middle
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return bands.idlePeriod() }
}

