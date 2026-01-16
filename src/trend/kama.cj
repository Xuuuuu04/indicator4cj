package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultKamaErPeriod: Int64 = 10
public const DefaultKamaFastScPeriod: Int64 = 2
public const DefaultKamaSlowScPeriod: Int64 = 30

// Kaufman's Adaptive Moving Average (KAMA)
public class Kama {
    // 效率周期
    public var erPeriod: Int64 = DefaultKamaErPeriod
    // 快速平滑周期
    public var fastScPeriod: Int64 = DefaultKamaFastScPeriod
    // 慢速平滑周期
    public var slowScPeriod: Int64 = DefaultKamaSlowScPeriod

    public Kama() {
        this.erPeriod = erPeriod
        this.fastScPeriod = fastScPeriod
        this.slowScPeriod = slowScPeriod
    }

    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.erPeriod = erPeriod
        this.fastScPeriod = fastScPeriod
        this.slowScPeriod = slowScPeriod
    }

    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let closingsSplice = duplicate(closings, 3)

        let directions = abs(change(closingsSplice[0], erPeriod))

        let movingSum = MovingSum()
        movingSum.period = erPeriod
        let volatilitys = movingSum.compute(abs(change(closingsSplice[1], 1)))

        let ers = divide(directions, volatilitys)

        let fastSc = 2.0 / Float64(fastScPeriod + 1)
        let slowSc = 2.0 / Float64(slowScPeriod + 1)

        let scs = pow(
            incrementBy(
                multiplyBy(
                    ers,
                    fastSc - slowSc
                ),
                slowSc
            ),
            2.0
        )

        let closingsShifted = skip(closingsSplice[2], erPeriod - 1)
        return KamaIterator(closingsShifted, scs)
    }

    public func idlePeriod(): Int64 { return erPeriod - 1 }

    public func toString(): String {
        return "KAMA(${erPeriod},${fastScPeriod},${slowScPeriod})"
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
