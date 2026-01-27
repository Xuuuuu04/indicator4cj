package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class StochRsiRow {
    public var close: Float64
    public var stochasticRsi: Float64
    public init() {
        this.close = 0.0
        this.stochasticRsi = 0.0
    }
}

@Test
public func stochastic_rsi_basic() {
    let input = Csv<StochRsiRow>().readFromFile("src/test/testdata/momentum/stochastic_rsi.csv")
    let inputs = duplicate(input, 2)
    let closes = map(inputs[0], { d: StochRsiRow => d.close })
    let expected = map(inputs[1], { d: StochRsiRow => d.stochasticRsi })

    let sr = StochasticRsi()
    let actual = roundDigits(sr.compute(closes), 2)
    let expectedAligned = roundDigits(skip(expected, sr.idlePeriod()), 2)

    match (checkEquals(actual, expectedAligned)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

