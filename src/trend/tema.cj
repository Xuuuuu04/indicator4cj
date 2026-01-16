package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

// 三重指数移动平均线(TEMA) = 3*EMA1 - 3*EMA2 + EMA3
public class Tema {
    // 快速EMA
    public let Ema1: Ema
    // 中速EMA
    public let Ema2: Ema
    // 慢速EMA
    public let Ema3: Ema

    public Tema() {
        this.Ema1 = Ema()
        this.Ema2 = Ema()
        this.Ema3 = Ema()
    }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Duplicate(Ema1.compute(c), 2)
        let ema2 = Duplicate(Ema2.compute(ema1[0]), 2)

        ema1[1] = Skip(ema1[1], Ema2.period - 1)

        let ema3 = Ema3.compute(ema2[0])
        ema1[1] = Skip(ema1[1], Ema3.period - 1)
        ema2[1] = Skip(ema2[1], Ema3.period - 1)

        let tema = Add(
            Subtract(
                MultiplyBy(ema1[1], 3.0),
                MultiplyBy(ema2[1], 3.0)
            ),
            ema3
        )

        return tema
    }

    public func idlePeriod(): Int64 {
        return Ema1.period + Ema2.period + Ema3.period - 3
    }
}
