package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Force Index.
public class Fi {
    private let ema = Ema()

    public Fi() { ema.period = 13 }
    public init(period: Int64) { ema.period = period }

    // compute 计算力量指数指标。
    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return ema.compute(
            Multiply(
                Change(closings, 1),
                volumes
            )
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return ema.idlePeriod() + 1 }
}

