package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TrixData {
    public var Close: Float64 = 0.0
    public var Trix: Float64 = 0.0
}

@Test
public func test_trix_basic() {
    let input = ReadFromCsvFile<TrixData>("src/test/testdata/trend/trix.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: TrixData => d.Close })
    let expected = h.Map(inputs[1], { d: TrixData => d.Trix })

    let trix = Trix()
    let actual = h.RoundDigits(trix.Compute(closing), 4)
    let expectedSkipped = h.Skip(expected, trix.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
