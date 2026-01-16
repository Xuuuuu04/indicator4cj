package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// 投影振荡器（Float64）。
public class Po {
    // 最小二乘指标
    private let _mls: Mls
    // 最小值指标
    private let _min: MovingMin
    // 最大值指标
    private let _max: MovingMax

    public init() {
        this._mls = Mls(14)
        this._min = MovingMin(14)
        this._max = MovingMax(14)
    }

    public init(period: Int64) {
        this._mls = Mls(period)
        this._min = MovingMin(period)
        this._max = MovingMax(period)
    }

    // compute 计算投影振荡器指标。
    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)
        let cs = Duplicate(closings, 2)

        let x = Map(Count(1, cs[0]), { i: Int64 => Float64(i) })
        let xSplice = Duplicate(x, 2)

        // PL = Min(周期, (最高价 + MLS(周期, x, 最高价)))
        let (plM, plB) = _mls.compute(xSplice[0], hs[0])
        Drain(plB)
        hs[1] = Skip(hs[1], _mls.idlePeriod())
        let plSplice = Duplicate(
            _min.compute(
                Add(hs[1], plM)
            ),
            2
        )

        // PH = Max(周期, (最低价 + MLS(周期, x, 最低价)))
        let (phM, phB) = _mls.compute(xSplice[1], ls[0])
        Drain(phB)
        ls[1] = Skip(ls[1], _mls.idlePeriod())
        let ph = _max.compute(Add(ls[1], phM))

        // PO = 100 * (收盘价 - PL) / (PH - PL)
        cs[1] = Skip(cs[1], _mls.idlePeriod() + _min.idlePeriod())
        let po = MultiplyBy(
            Divide(
                Subtract(cs[1], plSplice[0]),
                Subtract(ph, plSplice[1])
            ),
            100.0
        )

        return po
    }

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 {
        return _mls.idlePeriod() + _min.idlePeriod()
    }
}

