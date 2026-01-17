package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * DonchianChannel 唐奇安通道
 *
 * 计算唐奇安通道，由上轨(最高价)、中轨和下轨(最低价)组成。
 */
public class DonchianChannel {
    // 最大值指标
    private let _max: MovingMax
    // 最小值指标
    private let _min: MovingMin

    public DonchianChannel() {
        this._max = MovingMax(DONCHIAN_CHANNEL_DEFAULT_PERIOD)
        this._min = MovingMin(DONCHIAN_CHANNEL_DEFAULT_PERIOD)
    }

    public init(period: Int64) {
        this._max = MovingMax(period)
        this._min = MovingMin(period)
    }

/**
 * compute 计算唐奇安通道
 *
 * 计算唐奇安通道，由上轨(最高价)、中轨和下轨(最低价)组成。
 *
 * @param values 价格数据迭代器
 * @return 元组：(上轨迭代器, 中轨迭代器, 下轨迭代器)
 */
    public func compute(values: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let duplicatedValues = duplicate(values, 2)

        let uppers = duplicate(_max.compute(duplicatedValues[0]), 2)
        let lowers = duplicate(_min.compute(duplicatedValues[1]), 2)

        let middle = divideBy(
            add(uppers[0], lowers[0]),
            2.0
        )

        return (uppers[1], middle, lowers[1])
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _max.idlePeriod() }
}

