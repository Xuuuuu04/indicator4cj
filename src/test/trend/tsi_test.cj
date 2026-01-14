package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TsiData {
    public var Close: Float64 = 0.0
    public var Tsi: Float64 = 0.0
}

@Test
public func test_tsi_basic() {
    let input = ReadFromCsvFile<TsiData>("src/test/testdata/trend/tsi.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: TsiData => d.Close })
    let expected = h.Map(inputs[1], { d: TsiData => d.Tsi })

    let tsi = Tsi()
    let actual = h.RoundDigits(tsi.compute(closing), 2)
    let expectedSkipped = h.Skip(expected, tsi.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
