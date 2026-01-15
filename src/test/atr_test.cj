package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class AtrRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let Atr: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Atr: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.Atr = Atr
    }
}

@Test
public func atr_basic() {
    let input = Csv<AtrRow>().readFromFile("src/test/testdata/volatility/atr.csv")
    let inputs = Duplicate(input, 4)
    let highs = Map(inputs[0], { d: AtrRow => d.high })
    let lows = Map(inputs[1], { d: AtrRow => d.low })
    let closings = Map(inputs[2], { d: AtrRow => d.close })
    var expected = Map(inputs[3], { d: AtrRow => d.Atr })

    let atr = Atr(50)
    var actual = RoundDigits(atr.compute(highs, lows, closings), 2)
    expected = Skip(expected, atr.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

