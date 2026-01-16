package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class KeltnerChannel {
    // ATR指标
    private let atr: Atr
    // 指标
    private let ema: Ema

    public KeltnerChannel() {
        this.atr = Atr(20)
        this.ema = Ema(20)
    }

    public init(period: Int64) {
        this.atr = Atr(period)
        this.ema = Ema(period)
    }

    // compute 计算肯特纳通道指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closes = Duplicate(closings, 2)

        let atrs = Duplicate(
            MultiplyBy(
                atr.compute(highs, lows, closes[0]),
                2.0
            ),
            2
        )

        let skipCnt = atr.idlePeriod() - ema.idlePeriod()
        let middles = Duplicate(
            Skip(ema.compute(closes[1]), skipCnt),
            3
        )

        let upper = Add(middles[0], atrs[0])
        let lower = Subtract(middles[1], atrs[1])

        return (upper, middles[2], lower)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return atr.idlePeriod() }
}

