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
    let inputs = duplicate(input, 4)
    let highs = map(inputs[0], { d: WilliamsRRow => d.high })
    let lows = map(inputs[1], { d: WilliamsRRow => d.low })
    let closes = map(inputs[2], { d: WilliamsRRow => d.close })
    var expected = map(inputs[3], { d: WilliamsRRow => d.WilliamsR })

    let wr = WilliamsR(14)
    var actual = wr.compute(highs, lows, closes)
    actual = roundDigits(actual, 2)
    expected = skip(expected, wr.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

