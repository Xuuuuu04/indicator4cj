package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class WilliamsRRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let WilliamsR: Float64
    public init(High: Float64, Low: Float64, Close: Float64, WilliamsR: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.WilliamsR = WilliamsR
    }
}

@Test
public func williams_r_basic() {
    let input = ReadFromCsvFile<WilliamsRRow>("src/test/testdata/momentum/williams_r.csv")
    let inputs = Duplicate(input, 4)
    let highs = Map(inputs[0], { d: WilliamsRRow => d.High })
    let lows = Map(inputs[1], { d: WilliamsRRow => d.Low })
    let closes = Map(inputs[2], { d: WilliamsRRow => d.Close })
    var expected = Map(inputs[3], { d: WilliamsRRow => d.WilliamsR })

    let wr = WilliamsR(14)
    var actual = wr.compute(highs, lows, closes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, wr.IdlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

