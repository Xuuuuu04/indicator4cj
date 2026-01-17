package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*

public class BollingerBandWidth {
    // 布林带指标
    private let _bands = BollingerBands()

    public BollingerBandWidth() {
    }

/**
 * compute 计算布林带宽度
 *
 * 计算布林带宽度 = (上轨 - 下轨) / 中轨。
 * 用于衡量市场波动性。
 *
 * @param values 价格数据迭代器
 * @return 布林带宽度迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let (upperBand, middleBand, lowerBand) = _bands.compute(values)
        return divide(
            subtract(upperBand, lowerBand),
            middleBand
        )
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return _bands.idlePeriod() }
}

