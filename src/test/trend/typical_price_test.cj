package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TypicalPriceData {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var TypicalPrice: Float64 = 0.0
}

@Test
public func test_typical_price_basic() {
    let input = Csv<TypicalPriceData>().readFromFile("src/test/testdata/trend/typical_price.csv")
    let inputs = duplicate(input, 4)
    let high = h.map(inputs[0], { d: TypicalPriceData => d.high })
    let low = h.map(inputs[1], { d: TypicalPriceData => d.low })
    let closing = h.map(inputs[2], { d: TypicalPriceData => d.close })
    let expected = h.map(inputs[3], { d: TypicalPriceData => d.TypicalPrice })

    let typicalPrice = TypicalPrice()
    let actual = h.roundDigits(typicalPrice.compute(high, low, closing), 2)

    match (h.checkFloatEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
