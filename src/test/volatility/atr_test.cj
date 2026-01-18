package indicator4cj.test.volatility

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
    let inputs = duplicate(input, 4)
    let highs = map(inputs[0], { d: AtrRow => d.high })
    let lows = map(inputs[1], { d: AtrRow => d.low })
    let closings = map(inputs[2], { d: AtrRow => d.close })
    var expected = map(inputs[3], { d: AtrRow => d.Atr })

    let atr = Atr(50)
    var actual = roundDigits(atr.compute(highs, lows, closings), 2)
    expected = skip(expected, atr.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

