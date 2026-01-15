package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class StochRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let K: Float64
    public let D: Float64
    public init(High: Float64, Low: Float64, Close: Float64, K: Float64, D: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.K = K
        this.D = D
    }
}

@Test
public func stochastic_oscillator_basic() {
    let input = ReadFromCsvFile<StochRow>("src/test/testdata/momentum/stochastic_oscillator.csv")
    let inputs = Duplicate(input, 5)
    let highs = Map(inputs[0], { d: StochRow => d.High })
    let lows = Map(inputs[1], { d: StochRow => d.Low })
    let closes = Map(inputs[2], { d: StochRow => d.Close })
    var expK = Map(inputs[3], { d: StochRow => d.K })
    var expD = Map(inputs[4], { d: StochRow => d.D })

    let so = StochasticOscillator()
    var (actK, actD) = so.compute(highs, lows, closes)
    actK = RoundDigits(actK, 2)
    actD = RoundDigits(actD, 2)

    let skip = so.idlePeriod()
    expK = Skip(expK, skip)
    expD = Skip(expD, skip)

    match (CheckEquals(actK, expK)) { case Some(err) => fail("K " + err) case None => () }
    match (CheckEquals(actD, expD)) { case Some(err) => fail("D " + err) case None => () }
}

