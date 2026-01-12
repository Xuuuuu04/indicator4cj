package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class SuperTrend {
    private let _atr: Atr
    private let _multiplier: Float64

    public init() {
        this._atr = Atr(Hma(14))
        this._multiplier = 2.5
    }

    public init(period: Int64, multiplier: Float64) {
        this._atr = Atr(Hma(period))
        this._multiplier = multiplier
    }

    public func Compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)
        let cs = Duplicate(closings, 2)

        let medians = Skip(
            DivideBy(
                Add(hs[0], ls[0]),
                2.0
            ),
            _atr.IdlePeriod()
        )

        let atrMult = MultiplyBy(
            _atr.Compute(hs[1], ls[1], cs[0]),
            _multiplier
        )

        cs[1] = Skip(cs[1], _atr.IdlePeriod())

        return SuperTrendIterator(medians, atrMult, cs[1])
    }

    public func IdlePeriod(): Int64 { return _atr.IdlePeriod() }
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

