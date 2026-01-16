package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TsiData {
    public var close: Float64 = 0.0
    public var Tsi: Float64 = 0.0
}

@Test
public func test_tsi_basic() {
    let input = Csv<TsiData>().readFromFile("src/test/testdata/trend/tsi.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { d: TsiData => d.close })
    let expected = h.map(inputs[1], { d: TsiData => d.Tsi })

    let tsi = Tsi()
    let actual = h.roundDigits(tsi.compute(closing), 2)
    let expectedSkipped = h.skip(expected, tsi.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
