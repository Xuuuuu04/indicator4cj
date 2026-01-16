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

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let ema1 = duplicate(this.ema1.compute(c), 2)
        let ema2 = duplicate(this.ema2.compute(ema1[0]), 2)

        ema1[1] = skip(ema1[1], this.ema2.period - 1)

        let ema3 = this.ema3.compute(ema2[0])
        ema1[1] = skip(ema1[1], this.ema3.period - 1)
        ema2[1] = skip(ema2[1], this.ema3.period - 1)

        let tema = add(
            subtract(
                multiplyBy(ema1[1], 3.0),
                multiplyBy(ema2[1], 3.0)
            ),
            ema3
        )

        return tema
    }

    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period + this.ema3.period - 3
    }
}
