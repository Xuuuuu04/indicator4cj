package indicator4cj.trend

import std.core.*

public const DefaultTrimaPeriod: Int64 = 15

// 三角移动平均线（TRIMA）
public class Trima {
    // 周期
    public var period: Int64 = DefaultTrimaPeriod

    public Trima() {
        // 使用默认值
    }

    public init(period: Int64) {
        this.period = period
    }

/**
 * compute 计算三角移动平均线
 *
 * 计算TRIMA，对SMA再次进行平均，权重呈三角形分布。
 *
 * @param values 价格数据迭代器
 * @return TRIMA值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let (p1, p2) = calculatePeriods()
        let sma1 = Sma(p1)
        let sma2 = Sma(p2)
        return sma1.compute(sma2.compute(values))
    }

    public func idlePeriod(): Int64 {
        let (p1, p2) = calculatePeriods()
        return p1 + p2 - 2
    }

    private func calculatePeriods(): (Int64, Int64) {
        var p1: Int64
        var p2: Int64
        if (period % 2 == 0) {
            p1 = period / 2
            p2 = p1 + 1
        } else {
            p1 = (period + 1) / 2
            p2 = p1
        }
        return (p1, p2)
    }

    public func toString(): String { return "TRIMA(${period})" }
}
