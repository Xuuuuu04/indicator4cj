package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * MACD 默认参数常量
 */
public const DEFAULT_MACD_PERIOD1: Int64 = MACD_DEFAULT_FAST_PERIOD
public const DEFAULT_MACD_PERIOD2: Int64 = MACD_DEFAULT_SLOW_PERIOD
public const DEFAULT_MACD_PERIOD3: Int64 = MACD_DEFAULT_SIGNAL_PERIOD

/**
 * Macd 移动平均收敛散度指标
 * MACD = EMA(周期1) - EMA(周期2)；信号线 = MACD的EMA(周期3)
 */
public class Macd {
    /** 快速EMA */
    public let ema1: Ema
    /** 慢速EMA */
    public let ema2: Ema
    /** 信号EMA */
    public let ema3: Ema

    public Macd() {
        this.ema1 = Ema(DEFAULT_MACD_PERIOD1)
        this.ema2 = Ema(DEFAULT_MACD_PERIOD2)
        this.ema3 = Ema(DEFAULT_MACD_PERIOD3)
    }

    public init(period1: Int64, period2: Int64, period3: Int64) {
        this.ema1 = Ema(period1)
        this.ema2 = Ema(period2)
        this.ema3 = Ema(period3)
    }

/**
 * compute 计算MACD指标
 *
 * 计算移动平均收敛散度(MACD)。
 * MACD线 = 快速EMA - 慢速EMA
 * 信号线 = MACD的EMA
 *
 * @param values 价格数据迭代器
 * @return 元组：(MACD线迭代器, 信号线迭代器)
 */
    public func compute(values: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>) {
        let duplicatedValues = duplicate(values, 2)
        var fastEma = this.ema1.compute(duplicatedValues[0])
        fastEma = skip(fastEma, this.ema2.period - this.ema1.period)
        let slowEma = this.ema2.compute(duplicatedValues[1])

        let macdLines = duplicate(subtract(fastEma, slowEma), 2)
        macdLines[0] = skip(macdLines[0], this.ema3.period - 1)
        let signalLine = this.ema3.compute(macdLines[1])
        return (macdLines[0], signalLine)
    }

/**
 * idlePeriod 返回空闲周期数
 * @return 空闲周期数
 */
    public func idlePeriod(): Int64 {
        return this.ema2.period + this.ema3.period - 2
    }
}

public func newMacd(): Macd {
    return Macd()
}

public func newMacdWithPeriod(period1: Int64, period2: Int64, period3: Int64): Macd {
    return Macd(period1, period2, period3)
}
