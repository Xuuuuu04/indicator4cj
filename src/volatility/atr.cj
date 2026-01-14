package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Average True Range (ATR) with pluggable moving average (Ma).
public class Atr {
    public var ma: Ma

    public init() { this.ma = Sma(14) }
    public init(period: Int64) { this.ma = Sma(period) }
    public init(ma: Ma) { this.ma = ma }

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        // align highs/lows to use previous closing
        let hs = Skip(highs, 1)
        let ls = Skip(lows, 1)

        let tr = Operate3(hs, ls, closings, { h: Float64, l: Float64, c: Float64 =>
            let a = h - l
            let b = h - c
            let d = c - l
            let m = max(a, max(b, d))
            return m
        })

        return ma.compute(tr)
    }

    public func idlePeriod(): Int64 { return ma.idlePeriod() + 1 }
}

