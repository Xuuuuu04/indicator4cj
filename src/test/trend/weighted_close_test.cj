package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class WeightedCloseData {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var WeightedClose: Float64 = 0.0
}

@Test
public func test_weighted_close_basic() {
    let input = Csv<WeightedCloseData>().readFromFile("src/test/testdata/trend/weighted_close.csv")
    let inputs = Duplicate(input, 4)
    let high = h.Map(inputs[0], { d: WeightedCloseData => d.close })
    let low = h.Map(inputs[1], { d: WeightedCloseData => d.close })
    let closing = h.Map(inputs[2], { d: WeightedCloseData => d.close })
    let expected = h.Map(inputs[3], { d: WeightedCloseData => d.WeightedClose })

    let weightedClose = WeightedClose()
    let actual = h.RoundDigits(weightedClose.compute(high, low, closing), 2)
    let expectedSkipped = h.Skip(expected, weightedClose.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
