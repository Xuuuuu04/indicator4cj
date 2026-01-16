package indicator4cj.trend

import std.core.*
import std.math.*
import indicator4cj.helper.*

// Hull 移动平均线（HMA）（Float64）。
public class Hma {
    private let _wma1: Wma
    private let _wma2: Wma
    private let _wma3: Wma

    public Hma(period: Int64) {
        // 根据经验，为了匹配 Go 的测试数据（hma.csv），我们必须使用四舍五入，
        // 尽管 Go 源代码建议截断。
        // 这表明 CSV 可能是用不同版本或逻辑生成的。
        let p1 = Int64(round(Float64(period) / 2.0))
        let p3 = Int64(round(sqrt(Float64(period))))

        this._wma1 = Wma(p1)
        this._wma2 = Wma(period)
        this._wma3 = Wma(p3)
    }

    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let vals = Duplicate(values, 2)

        let w1 = _wma1.compute(vals[0])
        let w2 = _wma2.compute(vals[1])

        let combined = Subtract(
            MultiplyBy(w1, 2.0),
            w2
        )

        return _wma3.compute(combined)
    }

    public func idlePeriod(): Int64 {
        return _wma1.idlePeriod() + _wma3.idlePeriod()
    }

    public func toString(): String { return "HMA(${_wma2.period})" }
}

// Hma 符合 Ma 接口。
extend Hma <: Ma {}
