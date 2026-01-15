package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class SuperTrend {
    private let atr: Atr
    private let multiplier: Float64

    public init() {
        this.atr = Atr(Hma(14))
        this.multiplier = 2.5
    }

    public init(period: Int64, multiplier: Float64) {
        this.atr = Atr(Hma(period))
        this.multiplier = multiplier
    }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)
        let cs = Duplicate(closings, 2)

        let medians = Skip(
            DivideBy(
                Add(hs[0], ls[0]),
                2.0
            ),
            atr.idlePeriod()
        )

        let atrMult = MultiplyBy(
            atr.compute(hs[1], ls[1], cs[0]),
            multiplier
        )

        cs[1] = Skip(cs[1], atr.idlePeriod())

        return SuperTrendIterator(medians, atrMult, cs[1])
    }

    public func idlePeriod(): Int64 { return atr.idlePeriod() }
}

private class SuperTrendIterator <: Iterator<Float64> {
    private let medians: Iterator<Float64>
    private let atrs: Iterator<Float64>
    private let closes: Iterator<Float64>

    private var isFirst: Bool = true
    private var upTrend: Bool = false
    private var prevClose: Float64 = 0.0
    private var finalUpper: Float64 = 0.0
    private var finalLower: Float64 = 0.0

    public init(medians: Iterator<Float64>, atrs: Iterator<Float64>, closes: Iterator<Float64>) {
        this.medians = medians
        this.atrs = atrs
        this.closes = closes
    }

    public func next(): Option<Float64> {
        match (medians.next()) {
            case Some(median) =>
                match (atrs.next()) {
                    case Some(a) =>
                        match (closes.next()) {
                            case Some(close) =>
                                let basicUpper = median + a
                                let basicLower = median - a
                                var superVal = 0.0

                                if (isFirst) {
                                    isFirst = false
                                    finalUpper = basicUpper
                                    finalLower = basicLower
                                    superVal = finalLower
                                } else {
                                    if ((basicUpper < finalUpper) || (prevClose > finalUpper)) {
                                        finalUpper = basicUpper
                                    }
                                    if ((basicLower > finalLower) || (prevClose < finalLower)) {
                                        finalLower = basicLower
                                    }

                                    if (upTrend) {
                                        if (close <= finalUpper) {
                                            superVal = finalUpper
                                        } else {
                                            superVal = finalLower
                                            upTrend = false
                                        }
                                    } else {
                                        if (close >= finalLower) {
                                            superVal = finalLower
                                        } else {
                                            superVal = finalUpper
                                            upTrend = true
                                        }
                                    }
                                }

                                prevClose = close
                                return Some(superVal)
                            case None => return None
                        }
                    case None => return None
                }
            case None => return None
        }
    }
}

