package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TypicalPriceData {
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var TypicalPrice: Float64 = 0.0
}

@Test
public func test_typical_price_basic() {
    let input = ReadFromCsvFile<TypicalPriceData>("src/test/testdata/trend/typical_price.csv")
    let inputs = Duplicate(input, 4)
    let high = h.Map(inputs[0], { d: TypicalPriceData => d.High })
    let low = h.Map(inputs[1], { d: TypicalPriceData => d.Low })
    let closing = h.Map(inputs[2], { d: TypicalPriceData => d.Close })
    let expected = h.Map(inputs[3], { d: TypicalPriceData => d.TypicalPrice })

    let typicalPrice = TypicalPrice()
    let actual = h.RoundDigits(typicalPrice.Compute(high, low, closing), 2)

    match (h.CheckFloatEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
