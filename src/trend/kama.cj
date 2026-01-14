package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultKamaErPeriod: Int64 = 10
public const DefaultKamaFastScPeriod: Int64 = 2
public const DefaultKamaSlowScPeriod: Int64 = 30

// Kaufman's Adaptive Moving Average (KAMA)
public class Kama {
    public var ErPeriod: Int64
    public var FastScPeriod: Int64
    public var SlowScPeriod: Int64

    public init() {
        this.ErPeriod = DefaultKamaErPeriod
        this.FastScPeriod = DefaultKamaFastScPeriod
        this.SlowScPeriod = DefaultKamaSlowScPeriod
    }

    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.ErPeriod = erPeriod
        this.FastScPeriod = fastScPeriod
        this.SlowScPeriod = slowScPeriod
    }

    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let closingsSplice = Duplicate(closings, 3)

        let directions = Abs(Change(closingsSplice[0], ErPeriod))

        let movingSum = MovingSum()
        movingSum.Period = ErPeriod
        let volatilitys = movingSum.compute(Abs(Change(closingsSplice[1], 1)))

        let ers = Divide(directions, volatilitys)

        let fastSc = 2.0 / Float64(FastScPeriod + 1)
        let slowSc = 2.0 / Float64(SlowScPeriod + 1)

        let scs = Pow(
            IncrementBy(
                MultiplyBy(
                    ers,
                    fastSc - slowSc
                ),
                slowSc
            ),
            2.0
        )

        let closingsShifted = Skip(closingsSplice[2], ErPeriod - 1)
        return KamaIterator(closingsShifted, scs)
    }

    public func idlePeriod(): Int64 { return ErPeriod - 1 }

    public func toString(): String {
        return "KAMA(${ErPeriod},${FastScPeriod},${SlowScPeriod})"
    }
}

private class KamaIterator <: Iterator<Float64> {
    private let _prices: Iterator<Float64>
    private let _scs: Iterator<Float64>
    private var _prev: Float64 = 0.0
    private var _seeded: Bool = false

    public init(prices: Iterator<Float64>, scs: Iterator<Float64>) {
        this._prices = prices
        this._scs = scs
    }

    public func next(): Option<Float64> {
        if (!_seeded) {
            match (_prices.next()) {
                case Some(p) =>
                    _prev = p
                    _seeded = true
                    return Some(_prev)
                case None => return None
            }
        }

        match (_prices.next()) {
            case Some(price) =>
                match (_scs.next()) {
                    case Some(sc) =>
                        _prev = _prev + sc * (price - _prev)
                        return Some(_prev)
                    case None => return None
                }
            case None => return None
        }
    }
}

