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
    let inputs = duplicate(input, 4)
    let high = h.map(inputs[0], { d: WeightedCloseData => d.close })
    let low = h.map(inputs[1], { d: WeightedCloseData => d.close })
    let closing = h.map(inputs[2], { d: WeightedCloseData => d.close })
    let expected = h.map(inputs[3], { d: WeightedCloseData => d.WeightedClose })

    let weightedClose = WeightedClose()
    let actual = h.roundDigits(weightedClose.compute(high, low, closing), 2)
    let expectedSkipped = h.skip(expected, weightedClose.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
