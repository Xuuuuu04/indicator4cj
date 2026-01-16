package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultMacdPeriod1: Int64 = 12
public const DefaultMacdPeriod2: Int64 = 26
public const DefaultMacdPeriod3: Int64 = 9

// MACD = EMA(周期1) - EMA(周期2)；信号线 = MACD的EMA(周期3)
public class Macd {
    // 快速EMA
    public let ema1: Ema
    // 慢速EMA
    public let ema2: Ema
    // 信号EMA
    public let ema3: Ema

    public Macd() {
        this.ema1 = Ema(DefaultMacdPeriod1)
        this.ema2 = Ema(DefaultMacdPeriod2)
        this.ema3 = Ema(DefaultMacdPeriod3)
    }

    public init(period1: Int64, period2: Int64, period3: Int64) {
        this.ema1 = Ema(period1)
        this.ema2 = Ema(period2)
        this.ema3 = Ema(period3)
    }

// compute 计算MACD指标。
    public func compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let snaps = Duplicate(c, 2)
        var ema1 = this.ema1.compute(snaps[0])
        ema1 = Skip(ema1, this.ema2.period - this.ema1.period)
        let ema2 = this.ema2.compute(snaps[1])

        let macds = Duplicate(Subtract(ema1, ema2), 2)
        macds[0] = Skip(macds[0], this.ema3.period - 1)
        let signal = this.ema3.compute(macds[1])
        return (macds[0], signal)
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return this.ema2.period + this.ema3.period - 2
    }
}

public func NewMacd(): Macd {
    return Macd()
}

public func NewMacdWithPeriod(period1: Int64, period2: Int64, period3: Int64): Macd {
    return Macd(period1, period2, period3)
}
