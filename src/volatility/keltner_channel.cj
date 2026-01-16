package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class KeltnerChannel {
    // ATR指标
    private let _atr: Atr
    // 指标
    private let _ema: Ema

    public KeltnerChannel() {
        this._atr = Atr(20)
        this._ema = Ema(20)
    }

    public init(period: Int64) {
        this._atr = Atr(period)
        this._ema = Ema(period)
    }

    // compute 计算肯特纳通道指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closes = duplicate(closings, 2)

        let atrs = duplicate(
            multiplyBy(
                _atr.compute(highs, lows, closes[0]),
                2.0
            ),
            2
        )

        let skipCnt = _atr.idlePeriod() - _ema.idlePeriod()
        let middles = duplicate(
            skip(_ema.compute(closes[1]), skipCnt),
            3
        )

        let upper = add(middles[0], atrs[0])
        let lower = subtract(middles[1], atrs[1])

        return (upper, middles[2], lower)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _atr.idlePeriod() }
}

