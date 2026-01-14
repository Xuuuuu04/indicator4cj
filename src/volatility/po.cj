package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Projection Oscillator (PO) for Float64.
public class Po {
    private let _mls: Mls
    private let _min: MovingMin
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

    public func compute(highs: Iterator<Float64>, lows: Iterator<Float64>, closings: Iterator<Float64>): Iterator<Float64> {
        let hs = Duplicate(highs, 2)
        let ls = Duplicate(lows, 2)
        let cs = Duplicate(closings, 2)

        let x = Map(Count(1, cs[0]), { i: Int64 => Float64(i) })
        let xSplice = Duplicate(x, 2)

        // PL = Min(period, (high + MLS(period, x, high)))
        let (plM, plB) = _mls.compute(xSplice[0], hs[0])
        Drain(plB)
        hs[1] = Skip(hs[1], _mls.idlePeriod())
        let plSplice = Duplicate(
            _min.compute(
                Add(hs[1], plM)
            ),
            2
        )

        // PH = Max(period, (low + MLS(period, x, low)))
        let (phM, phB) = _mls.compute(xSplice[1], ls[0])
        Drain(phB)
        ls[1] = Skip(ls[1], _mls.idlePeriod())
        let ph = _max.compute(Add(ls[1], phM))

        // PO = 100 * (Closing - PL) / (PH - PL)
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

    public func idlePeriod(): Int64 {
        return _mls.idlePeriod() + _min.idlePeriod()
    }
}

