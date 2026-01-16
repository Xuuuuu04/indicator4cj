package indicator4cj.volume

import std.core.*
import indicator4cj.helper.*

// 资金流量乘数（Float64）。
public class Mfm {
    public init() {
    }

    // compute 计算资金流量乘数指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = duplicate(highs, 2)
        let ls = duplicate(lows, 2)
        let cs = duplicate(closings, 2)
        return divide(
            subtract(
                subtract(cs[0], ls[0]),
                subtract(hs[0], cs[1])
            ),
            subtract(hs[1], ls[1])
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 0 }
}

