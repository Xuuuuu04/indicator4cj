package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultTrixPeriod: Int64 = 15

// 三重指数移动平均线(TRIX)：三重EMA的差值比率。
public class Trix {
    // 周期
    public var period: Int64 = DefaultTrixPeriod

    public Trix() {
        // 使用默认值
    }

    public init(period: Int64) {
        this.period = period
    }

/**
 * compute 计算三重指数平滑移动平均线
 *
 * 计算TRIX，用于过滤短期噪音。
 * 公式：TRIX = EMA(EMA(EMA(values)))的变化率
 *
 * @param values 价格数据迭代器
 * @return TRIX值迭代器（百分比形式）
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let ema1 = Ema(period)
        let ema2 = Ema(period)
        let ema3 = Ema(period)

        let tripleEma = ema3.compute(ema2.compute(ema1.compute(values)))
        let trixValue = changeRatio(tripleEma, 1)
        return trixValue
    }

// idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return (period * 3) - 3 + 1
    }
}
