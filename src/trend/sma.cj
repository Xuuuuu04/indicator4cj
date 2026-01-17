package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * Sma 简单移动平均线指标
 *
 * 计算简单移动平均线(SMA)，对周期内的数据进行算术平均。
 */
public class Sma {
    /** 周期 */
    public var period: Int64 = MA_DEFAULT_PERIOD

    public init() {
        // 使用默认值
    }

    public init(period: Int64) {
        if (period <= 0) {
            throw Exception("[SMA] period must be positive, got ${period}")
        }
        this.period = period
    }

/**
 * compute 计算简单移动平均线
 *
 * 计算指定周期的简单移动平均线(SMA)，对周期内的数据进行算术平均。
 *
 * @param values 价格数据迭代器
 * @return SMA值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let sum = MovingSum()
        sum.period = period
        return divideBy(sum.compute(values), Float64(period))
    }

/**
 * idlePeriod 返回空闲周期数
 * @return 空闲周期数
 */
    public func idlePeriod(): Int64 { return period - 1 }

/**
 * toString 返回指标的字符串表示
 * @return 字符串表示
 */
    public func toString(): String { return "SMA(${period})" }
}

