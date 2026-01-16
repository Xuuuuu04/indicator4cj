package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// 资金流量（Float64）。
public class Mfv {
    private let _mfm = Mfm()

    public init() {
    }

    // compute 计算资金流量指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        return Multiply(
            _mfm.compute(highs, lows, closings),
            volumes
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 0 }
}

