package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class PoRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let Po: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Po: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.Po = Po
    }
}

@Test
public func po_basic() {
    let input = Csv<PoRow>().readFromFile("src/test/testdata/volatility/po.csv")
    let inputs = Duplicate(input, 4)
    let highs = Map(inputs[0], { d: PoRow => d.high })
    let lows = Map(inputs[1], { d: PoRow => d.low })
    let closings = Map(inputs[2], { d: PoRow => d.close })
    var expected = Map(inputs[3], { d: PoRow => d.Po })

    let po = Po(50)
    var actual = RoundDigits(po.compute(highs, lows, closings), 2)
    expected = Skip(expected, po.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

