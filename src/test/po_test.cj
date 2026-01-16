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
    let inputs = duplicate(input, 4)
    let highs = map(inputs[0], { d: PoRow => d.high })
    let lows = map(inputs[1], { d: PoRow => d.low })
    let closings = map(inputs[2], { d: PoRow => d.close })
    var expected = map(inputs[3], { d: PoRow => d.Po })

    let po = Po(50)
    var actual = roundDigits(po.compute(highs, lows, closings), 2)
    expected = skip(expected, po.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

