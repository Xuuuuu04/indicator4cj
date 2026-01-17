package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * BollingerBands 布林带指标
 *
 * 计算布林带，由上轨、中轨（SMA）和下轨组成，用于判断价格是否超买或超卖。
 */
public class BollingerBands {
    // 周期
    public var period: Int64 = BOLLINGER_BANDS_DEFAULT_PERIOD

    public BollingerBands() {
        // 使用默认值 20
    }

    public init(period: Int64) {
        this.period = period
    }

/**
 * compute 计算布林带指标
 *
 * 计算布林带，由上轨、中轨（SMA）和下轨组成，用于判断价格是否超买或超卖。
 *
 * @param values 价格数据迭代器
 * @return 元组：(上轨迭代器, 中轨迭代器, 下轨迭代器)
 */
    public func compute(values: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let duplicatedValues = duplicate(values, 2)
        let sma = Sma()
        sma.period = period
        let std = MovingStd()
        std.period = period

        let middleBands = duplicate(
            sma.compute(duplicatedValues[0]),
            3
        )

        let stdDeviations = duplicate(
            multiplyBy(std.compute(duplicatedValues[1]), BOLLINGER_BANDS_MULTIPLIER),
            2
        )

        let upperBand = add(middleBands[0], stdDeviations[0])
        let lowerBand = subtract(middleBands[1], stdDeviations[1])

        return (upperBand, middleBands[2], lowerBand)
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return period - 1 }
}

