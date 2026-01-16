package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// 绝妙振荡器 = SMA(最高价/最低价中位数, 5) - SMA(最高价/最低价中位数, 34)
public class AwesomeOscillator {
    // compute 计算绝妙振荡器指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>): Iterator<Float64> {
        let medianDup = Duplicate(
            DivideBy(
                Add(highs, lows),
                2.0
            ),
            2
        )
        let s5 = Sma()
        s5.period = 5
        let s34 = Sma()
        s34.period = 34
        var fast = s5.compute(medianDup[0])
        var slow = s34.compute(medianDup[1])
        // 对齐：跳过 fast 前 (34-5)=29 个值，使两条均从 index 33 开始。
        fast = Skip(fast, 29)
        return Subtract(fast, slow)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 34 - 1 }
}

