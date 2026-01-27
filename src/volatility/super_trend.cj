package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class SuperTrend {
    // ATR指标
    private let _atr: Atr
    // 倍数
    private let _multiplier: Float64

    public init() {
        this._atr = Atr(Hma(14))
        this._multiplier = 2.5
    }

    public init(period: Int64, multiplier: Float64) {
        this._atr = Atr(Hma(period))
        this._multiplier = multiplier
    }

    public init(ma: Ma, multiplier: Float64) {
        this._atr = Atr(ma)
        this._multiplier = multiplier
    }

    // compute 计算超级趋势指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = duplicate(highs, 2)
        let ls = duplicate(lows, 2)
        let cs = duplicate(closings, 2)

        let medians = skip(
            divideBy(
                add(hs[0], ls[0]),
                2.0
            ),
            _atr.idlePeriod()
        )

        let atrMult = multiplyBy(
            _atr.compute(hs[1], ls[1], cs[0]),
            _multiplier
        )

        cs[1] = skip(cs[1], _atr.idlePeriod())

        return SuperTrendIterator(medians, atrMult, cs[1])
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _atr.idlePeriod() }
}

private class SuperTrendIterator <: Iterator<Float64> {
    private let _medians: Iterator<Float64>
    private let _atrs: Iterator<Float64>
    private let _closes: Iterator<Float64>

    private var _isFirst: Bool = true
    private var _upTrend: Bool = false
    private var _prevClose: Float64 = 0.0
    private var _finalUpper: Float64 = 0.0
    private var _finalLower: Float64 = 0.0

    public init(medians: Iterator<Float64>, atrs: Iterator<Float64>, closes: Iterator<Float64>) {
        this._medians = medians
        this._atrs = atrs
        this._closes = closes
    }

    public func next(): Option<Float64> {
        match (_medians.next()) {
            case Some(median) =>
                match (_atrs.next()) {
                    case Some(a) =>
                        match (_closes.next()) {
                            case Some(close) =>
                                let basicUpper = median + a
                                let basicLower = median - a
                                var superVal = 0.0

                                if (_isFirst) {
                                    _isFirst = false
                                    _finalUpper = basicUpper
                                    _finalLower = basicLower
                                    superVal = _finalLower
                                } else {
                                    if ((basicUpper < _finalUpper) || (_prevClose > _finalUpper)) {
                                        _finalUpper = basicUpper
                                    }
                                    if ((basicLower > _finalLower) || (_prevClose < _finalLower)) {
                                        _finalLower = basicLower
                                    }

                                    if (_upTrend) {
                                        if (close <= _finalUpper) {
                                            superVal = _finalUpper
                                        } else {
                                            superVal = _finalLower
                                            _upTrend = false
                                        }
                                    } else {
                                        if (close >= _finalLower) {
                                            superVal = _finalLower
                                        } else {
                                            superVal = _finalUpper
                                            _upTrend = true
                                        }
                                    }
                                }

                                _prevClose = close
                                return Some(superVal)
                            case None => return None
                        }
                    case None => return None
                }
            case None => return None
        }
    }
}

