package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// 蔡金振荡器 = EMA(累积派发线, 3) - EMA(累积派发线, 10)
public class ChaikinOscillator {
    // compute 计算蔡金振荡器指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closes: Iterator<Float64>, volumes: Iterator<Float64>): Iterator<Float64> {
        // AD = ((收盘价 - 最低价) - (最高价 - 收盘价)) / (最高价 - 最低价) * 成交量
        let hl = Subtract(highs, lows)
        let mfm = Divide(
            Subtract(
                Subtract(closes, lows),
                Subtract(highs, closes)
            ),
            hl
        )
        let ad = Multiply(mfm, volumes)

        let e3 = Ema(3)
        let e10 = Ema(10)
        return Subtract(e3.compute(ad), e10.compute(ad))
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 10 - 1 }
}

