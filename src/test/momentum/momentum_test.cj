package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class MomentumRow {
    public let Close: Float64
    public let Momentum: Float64
    public init(Close: Float64, Momentum: Float64) {
        this.Close = Close
        this.Momentum = Momentum
    }
}

@Test
public func momentum_basic() {
    let input = ReadFromCsvFile<MomentumRow>("src/test/testdata/momentum/momentum.csv")
    let inputs = Duplicate(input, 2)
    let closes = Map(inputs[0], { d: MomentumRow => d.Close })
    var expected = Map(inputs[1], { d: MomentumRow => d.Momentum })

    let m = Momentum(10)
    var actual = m.compute(closes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, m.IdlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

