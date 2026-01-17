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

/**
 * compute 计算双重指数移动平均线
 *
 * 计算DEMA，减少单次EMA的滞后性。
 * 公式：DEMA = 2*EMA - EMA(EMA)
 *
 * @param values 价格数据迭代器
 * @return DEMA值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let ema1Values = duplicate(this.ema1.compute(values), 2)
        let ema2Value = this.ema2.compute(ema1Values[1])

        var doubleEma1 = multiplyBy(ema1Values[0], 2.0)
        doubleEma1 = buffered(doubleEma1, this.ema2.period)

        return subtract(doubleEma1, ema2Value)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period - 2
    }
}

