package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultApoFastPeriod: Int64 = 14
public const DefaultApoFastSmoothing: Float64 = 2.0
public const DefaultApoSlowPeriod: Int64 = 30
public const DefaultApoSlowSmoothing: Float64 = 2.0

// Absolute Price Oscillator (APO) = EMA(fast) - EMA(slow)
public class Apo {
    public var FastPeriod: Int64
    public var FastSmoothing: Float64
    public var SlowPeriod: Int64
    public var SlowSmoothing: Float64

    public init() {
        this.FastPeriod = DefaultApoFastPeriod
        this.FastSmoothing = DefaultApoFastSmoothing
        this.SlowPeriod = DefaultApoSlowPeriod
        this.SlowSmoothing = DefaultApoSlowSmoothing
    }

    public func compute(c: Iterator<Float64>): Iterator<Float64> {
        // Buffered 为保持与 Go 签名一致（当前直通）
        let buffered = Buffered(c, this.SlowPeriod)
        let cs = Duplicate(buffered, 2)

        let fastEma = Ema(this.FastPeriod)
        fastEma.smoothing = this.FastSmoothing
        let slowEma = Ema(this.SlowPeriod)
        slowEma.smoothing = this.SlowSmoothing

        cs[0] = fastEma.compute(cs[0])
        cs[1] = slowEma.compute(cs[1])

        return Subtract(cs[0], cs[1])
    }

    // IdlePeriod 取慢周期，策略侧按 Go 版 Shift 使用。
    public func idlePeriod(): Int64 {
        return this.SlowPeriod
    }
}

