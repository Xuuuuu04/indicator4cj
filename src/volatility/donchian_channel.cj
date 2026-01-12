package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class DonchianChannel {
    private let _max: MovingMax
    private let _min: MovingMin

    public init() {
        this._max = MovingMax(20)
        this._min = MovingMin(20)
    }

    public init(period: Int64) {
        this._max = MovingMax(period)
        this._min = MovingMin(period)
    }

    public func Compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closings = Duplicate(c, 2)

        let uppers = Duplicate(_max.Compute(closings[0]), 2)
        let lowers = Duplicate(_min.Compute(closings[1]), 2)

        let middle = DivideBy(
            Add(uppers[0], lowers[0]),
            2.0
        )

        return (uppers[1], middle, lowers[1])
    }

    public func IdlePeriod(): Int64 { return _max.IdlePeriod() }
}

