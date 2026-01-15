package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class AtrRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let Atr: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Atr: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.Atr = Atr
    }
}

@Test
public func atr_basic() {
    let input = ReadFromCsvFile<AtrRow>("src/test/testdata/volatility/atr.csv")
    let inputs = Duplicate(input, 4)
    let highs = Map(inputs[0], { d: AtrRow => d.High })
    let lows = Map(inputs[1], { d: AtrRow => d.Low })
    let closings = Map(inputs[2], { d: AtrRow => d.Close })
    var expected = Map(inputs[3], { d: AtrRow => d.Atr })

    let atr = Atr(50)
    var actual = RoundDigits(atr.compute(highs, lows, closings), 2)
    expected = Skip(expected, atr.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

