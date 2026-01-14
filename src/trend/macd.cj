package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultMacdPeriod1: Int64 = 12
public const DefaultMacdPeriod2: Int64 = 26
public const DefaultMacdPeriod3: Int64 = 9

// MACD = EMA(period1) - EMA(period2); Signal = EMA(period3) of MACD
public class Macd {
    public let Ema1: Ema
    public let Ema2: Ema
    public let Ema3: Ema

    public init() {
        this.Ema1 = Ema(DefaultMacdPeriod1)
        this.Ema2 = Ema(DefaultMacdPeriod2)
        this.Ema3 = Ema(DefaultMacdPeriod3)
    }

    public init(period1: Int64, period2: Int64, period3: Int64) {
        this.Ema1 = Ema(period1)
        this.Ema2 = Ema(period2)
        this.Ema3 = Ema(period3)
    }

    public func compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let snaps = Duplicate(c, 2)
        var ema1 = Ema1.compute(snaps[0])
        ema1 = Skip(ema1, Ema2.Period - Ema1.Period)
        let ema2 = Ema2.compute(snaps[1])

        let macds = Duplicate(Subtract(ema1, ema2), 2)
        macds[0] = Skip(macds[0], Ema3.Period - 1)
        let signal = Ema3.compute(macds[1])
        return (macds[0], signal)
    }

    public func idlePeriod(): Int64 {
        return Ema2.Period + Ema3.Period - 2
    }
}

