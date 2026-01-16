package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

public const DefaultKamaErPeriod: Int64 = 10
public const DefaultKamaFastScPeriod: Int64 = 2
public const DefaultKamaSlowScPeriod: Int64 = 30

// Kaufman's Adaptive Moving Average (KAMA)
public class Kama {
    public var ErPeriod: Int64 = DefaultKamaErPeriod
    public var FastScPeriod: Int64 = DefaultKamaFastScPeriod
    public var SlowScPeriod: Int64 = DefaultKamaSlowScPeriod

    public Kama() {
        this.ErPeriod = ErPeriod
        this.FastScPeriod = FastScPeriod
        this.SlowScPeriod = SlowScPeriod
    }

    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.ErPeriod = erPeriod
        this.FastScPeriod = fastScPeriod
        this.SlowScPeriod = slowScPeriod
    }

    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let closingsSplice = Duplicate(closings, 3)

        let directions = Abs(Change(closingsSplice[0], this.ErPeriod))

        let movingSum = MovingSum()
        movingSum.period = this.ErPeriod
        let volatilitys = movingSum.compute(Abs(Change(closingsSplice[1], 1)))

        let ers = Divide(directions, volatilitys)

        let fastSc = 2.0 / Float64(this.FastScPeriod + 1)
        let slowSc = 2.0 / Float64(this.SlowScPeriod + 1)

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

        let closingsShifted = Skip(closingsSplice[2], this.ErPeriod - 1)
        return KamaIterator(closingsShifted, scs)
    }

    public func idlePeriod(): Int64 { return this.ErPeriod - 1 }

    public func toString(): String {
        return "KAMA(${this.ErPeriod},${this.FastScPeriod},${this.SlowScPeriod})"
    }
}

private class KamaIterator <: Iterator<Float64> {
    private let prices: Iterator<Float64>
    private let scs: Iterator<Float64>
    private var prev: Float64 = 0.0
    private var seeded: Bool = false

    public init(prices: Iterator<Float64>, scs: Iterator<Float64>) {
        this.prices = prices
        this.scs = scs
    }

    public func next(): Option<Float64> {
        if (!seeded) {
            match (prices.next()) {
                case Some(p) =>
                    prev = p
                    seeded = true
                    return Some(prev)
                case None => return None
            }
        }

        match (prices.next()) {
            case Some(price) =>
                match (scs.next()) {
                    case Some(sc) =>
                        prev = prev + sc * (price - prev)
                        return Some(prev)
                    case None => return None
                }
            case None => return None
        }
    }
}
