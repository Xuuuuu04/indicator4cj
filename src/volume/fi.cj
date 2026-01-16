package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// 强力指数。
public class Fi {
    private let _ema = Ema()

    public Fi() {
        _ema.period = 13
    }

    public init(period: Int64) {
        _ema.period = period
    }

    // compute 计算力量指数指标。
    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return _ema.compute(
            multiply(
                change(closings, 1),
                volumes
            )
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _ema.idlePeriod() + 1 }
}

