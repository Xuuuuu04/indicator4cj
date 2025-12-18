package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class KeltnerChannel {
    private let atr: Atr
    private let ema: Ema

    public init() {
        this.atr = Atr(20)
        this.ema = Ema(20)
    }

    public init(period: Int64) {
        this.atr = Atr(period)
        this.ema = Ema(period)
    }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closes = Duplicate(closings, 2)

        let atrs = Duplicate(
            MultiplyBy(
                atr.Compute(highs, lows, closes[0]),
                2.0
            ),
            2
        )

        let skipCnt = atr.IdlePeriod() - ema.IdlePeriod()
        let middles = Duplicate(
            Skip(ema.Compute(closes[1]), skipCnt),
            3
        )

        let upper = Add(middles[0], atrs[0])
        let lower = Subtract(middles[1], atrs[1])

        return (upper, middles[2], lower)
    }

    public func IdlePeriod(): Int64 { return atr.IdlePeriod() }
}

