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
        let closingsSplice = Duplicate(closings, 3)

        let directions = Abs(Change(closingsSplice[0], this.erPeriod))

        let movingSum = MovingSum()
        movingSum.period = this.erPeriod
        let volatilitys = movingSum.compute(Abs(Change(closingsSplice[1], 1)))

        let ers = Divide(directions, volatilitys)

        let fastSc = 2.0 / Float64(this.fastScPeriod + 1)
        let slowSc = 2.0 / Float64(this.slowScPeriod + 1)

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

        let closingsShifted = Skip(closingsSplice[2], this.erPeriod - 1)
        return KamaIterator(closingsShifted, scs)
    }

    public func idlePeriod(): Int64 { return this.erPeriod - 1 }

    public func toString(): String {
        return "KAMA(${this.erPeriod},${this.fastScPeriod},${this.slowScPeriod})"
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
