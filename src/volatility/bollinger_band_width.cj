package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    // 布林带指标
    private let _bands = BollingerBands()

    public BollingerBandWidth() {
    }

    // compute 计算布林带宽度指标。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let (upper, middle, lower) = _bands.compute(c)
        return divide(
            subtract(upper, lower),
            middle
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _bands.idlePeriod() }
}

