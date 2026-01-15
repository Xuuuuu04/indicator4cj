package indicator4cj.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

public class DonchianChannel {
    private let max: MovingMax
    private let min: MovingMin

    public DonchianChannel() {
        this.max = MovingMax(20)
        this.min = MovingMin(20)
    }

    public init(period: Int64) {
        this.max = MovingMax(period)
        this.min = MovingMin(period)
    }

    public func compute(c: Iterator<Float64>): (Iterator<Float64>, Iterator<Float64>, Iterator<Float64>) {
        let closings = Duplicate(c, 2)

        let uppers = Duplicate(max.compute(closings[0]), 2)
        let lowers = Duplicate(min.compute(closings[1]), 2)

        let middle = DivideBy(
            Add(uppers[0], lowers[0]),
            2.0
        )

        return (uppers[1], middle, lowers[1])
    }

    public func idlePeriod(): Int64 { return max.idlePeriod() }
}

