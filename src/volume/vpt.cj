package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// VPT：Volume Price Trend（Float64）。
public class Vpt {
    public init() {
    }

    // compute 计算成交量价格趋势指标。
    public func compute(closings: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        let ratios = multiply(
            changeRatio(closings, 1),
            skip(volumes, 1)
        )
        return mapWithPrevious(ratios, { prev: Float64, curr: Float64 => prev + curr }, 0.0)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 1 }
}

