package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class KeltnerChannel {
    private let _atr: Atr
    private let _ema: Ema

    public init() {
        this._atr = Atr(20)
        this._ema = Ema(20)
    }

    public init(period: Int64) {
        this._atr = Atr(period)
        this._ema = Ema(period)
    }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closes = Duplicate(closings, 2)

        let atrs = Duplicate(
            MultiplyBy(
                _atr.compute(highs, lows, closes[0]),
                2.0
            ),
            2
        )

        let skipCnt = _atr.idlePeriod() - _ema.idlePeriod()
        let middles = Duplicate(
            Skip(_ema.compute(closes[1]), skipCnt),
            3
        )

        let upper = Add(middles[0], atrs[0])
        let lower = Subtract(middles[1], atrs[1])

        return (upper, middles[2], lower)
    }

    public func idlePeriod(): Int64 { return _atr.idlePeriod() }
}

