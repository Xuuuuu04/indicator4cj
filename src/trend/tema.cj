package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// 三重指数移动平均线(TEMA) = 3*EMA1 - 3*EMA2 + EMA3
public class Tema {
    // 快速EMA
    public let ema1: Ema
    // 中速EMA
    public let ema2: Ema
    // 慢速EMA
    public let ema3: Ema

    public Tema() {
        this.ema1 = Ema()
        this.ema2 = Ema()
        this.ema3 = Ema()
    }

/**
 * compute 计算三重指数移动平均线
 *
 * 计算TEMA，进一步减少滞后性。
 * 公式：TEMA = 3*EMA1 - 3*EMA2 + EMA3
 *
 * @param values 价格数据迭代器
 * @return TEMA值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let ema1Values = duplicate(this.ema1.compute(values), 2)
        let ema2Values = duplicate(this.ema2.compute(ema1Values[0]), 2)

        ema1Values[1] = skip(ema1Values[1], this.ema2.period - 1)

        let ema3Value = this.ema3.compute(ema2Values[0])
        ema1Values[1] = skip(ema1Values[1], this.ema3.period - 1)
        ema2Values[1] = skip(ema2Values[1], this.ema3.period - 1)

        let temaValue = add(
            subtract(
                multiplyBy(ema1Values[1], 3.0),
                multiplyBy(ema2Values[1], 3.0)
            ),
            ema3Value
        )

        return temaValue
    }

    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period + this.ema3.period - 3
    }
}
