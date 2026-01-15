package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TrixData {
    public var close: Float64 = 0.0
    public var Trix: Float64 = 0.0
}

@Test
public func test_trix_basic() {
    let input = Csv<TrixData>().readFromFile("src/test/testdata/trend/trix.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: TrixData => d.close })
    let expected = h.Map(inputs[1], { d: TrixData => d.Trix })

    let trix = Trix()
    let actual = h.RoundDigits(trix.compute(closing), 4)
    let expectedSkipped = h.Skip(expected, trix.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
