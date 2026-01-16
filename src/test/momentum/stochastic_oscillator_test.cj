package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class StochRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let K: Float64
    public let D: Float64
    public init(High: Float64, Low: Float64, Close: Float64, K: Float64, D: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.K = K
        this.D = D
    }
}

@Test
public func stochastic_oscillator_basic() {
    let input = Csv<StochRow>().readFromFile("src/test/testdata/momentum/stochastic_oscillator.csv")
    let inputs = duplicate(input, 5)
    let highs = map(inputs[0], { d: StochRow => d.high })
    let lows = map(inputs[1], { d: StochRow => d.low })
    let closes = map(inputs[2], { d: StochRow => d.close })
    var expK = map(inputs[3], { d: StochRow => d.K })
    var expD = map(inputs[4], { d: StochRow => d.D })

    let so = StochasticOscillator()
    var (actK, actD) = so.compute(highs, lows, closes)
    actK = roundDigits(actK, 2)
    actD = roundDigits(actD, 2)

    let skipCount = so.idlePeriod()
    expK = skip(expK, skipCount)
    expD = skip(expD, skipCount)

    match (checkEquals(actK, expK)) { case Some(err) => fail("K " + err) case None => () }
    match (checkEquals(actD, expD)) { case Some(err) => fail("D " + err) case None => () }
}

