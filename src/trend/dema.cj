package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// 双重指数移动平均线(DEMA) = 2*EMA1 - EMA2(EMA1)
public class Dema {
    // 快速EMA
    public let ema1: Ema
    // 慢速EMA
    public let ema2: Ema

    public Dema() {
        this.ema1 = Ema()
        this.ema2 = Ema()
    }

    // compute 计算双重指数移动平均线。
    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let ema1 = duplicate(this.ema1.compute(c), 2)
        let ema2 = this.ema2.compute(ema1[1])

        var doubleEma1 = multiplyBy(ema1[0], 2.0)
        doubleEma1 = buffered(doubleEma1, this.ema2.period)

        return subtract(doubleEma1, ema2)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period - 2
    }
}

