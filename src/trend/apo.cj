package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultApoFastPeriod: Int64 = 14
public const DefaultApoFastSmoothing: Float64 = 2.0
public const DefaultApoSlowPeriod: Int64 = 30
public const DefaultApoSlowSmoothing: Float64 = 2.0

// 绝对价格震荡指标(APO) = EMA(快速周期) - EMA(慢速周期)
public class Apo {
    // 快速周期
    public var fastPeriod: Int64
    // 快速平滑
    public var fastSmoothing: Float64
    // 慢速周期
    public var slowPeriod: Int64
    // 慢速平滑
    public var slowSmoothing: Float64

    public Apo() {
        this.fastPeriod = DefaultApoFastPeriod
        this.fastSmoothing = DefaultApoFastSmoothing
        this.slowPeriod = DefaultApoSlowPeriod
        this.slowSmoothing = DefaultApoSlowSmoothing
    }

/**
 * compute 计算绝对价格震荡指标
 *
 * 计算APO，衡量两个EMA之间的差异。
 * 公式：APO = EMA(快速) - EMA(慢速)
 *
 * @param values 价格数据迭代器
 * @return APO值迭代器
 */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        // Buffered 为保持与 Go 签名一致（当前直通）
        let buffered = buffered(values, slowPeriod)
        let duplicatedValues = duplicate(buffered, 2)

        let fastEma = Ema(fastPeriod)
        fastEma.smoothing = fastSmoothing
        let slowEma = Ema(slowPeriod)
        slowEma.smoothing = slowSmoothing

        duplicatedValues[0] = fastEma.compute(duplicatedValues[0])
        duplicatedValues[1] = slowEma.compute(duplicatedValues[1])

        return subtract(duplicatedValues[0], duplicatedValues[1])
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return slowPeriod
    }
}

