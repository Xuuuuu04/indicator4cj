package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class RsiRow {
    public let Close: Float64
    public let Rsi: Float64
    public init(Close: Float64, Rsi: Float64) {
        this.Close = Close
        this.Rsi = Rsi
    }
}

@Test
public func rsi_basic() {
    let input = ReadFromCsvFile<RsiRow>("src/test/testdata/momentum/rsi.csv")
    let inputs = Duplicate(input, 2)
    let closes = Map(inputs[0], { d: RsiRow => d.Close })
    var expected = Map(inputs[1], { d: RsiRow => d.Rsi })

    let rsi = Rsi(14)
    var actual = rsi.Compute(closes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, rsi.IdlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

