package indicator4cj.trend

import std.core.*

// 通用移动平均接口，供 ATR/SuperTrend 等复用。
public interface Ma {
    func Compute(c: Iterator<Float64>): Iterator<Float64>
    func IdlePeriod(): Int64
}

// Sma 已满足接口签名，使用扩展声明实现。
extend Sma <: Ma {}
// Ema 也实现 Ma 接口。
extend Ema <: Ma {}

