package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class WilliamsRRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let WilliamsR: Float64
    public init(High: Float64, Low: Float64, Close: Float64, WilliamsR: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.WilliamsR = WilliamsR
    }
}

@Test
public func williams_r_basic() {
    let input = Csv<WilliamsRRow>().readFromFile("src/test/testdata/momentum/williams_r.csv")
    let inputs = Duplicate(input, 4)
    let highs = Map(inputs[0], { d: WilliamsRRow => d.high })
    let lows = Map(inputs[1], { d: WilliamsRRow => d.low })
    let closes = Map(inputs[2], { d: WilliamsRRow => d.close })
    var expected = Map(inputs[3], { d: WilliamsRRow => d.WilliamsR })

    let wr = WilliamsR(14)
    var actual = wr.compute(highs, lows, closes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, wr.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

