package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TrimaData {
    public var Close: Float64 = 0.0
    public var Trima: Float64 = 0.0
}

@Test
public func test_trima_odd_basic() {
    let input = ReadFromCsvFile<TrimaData>("src/test/testdata/trend/trima_odd.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: TrimaData => d.Close })
    let expected = h.Map(inputs[1], { d: TrimaData => d.Trima })

    let trima = Trima()
    trima.Period = 15
    let actual = h.RoundDigits(trima.Compute(closing), 2)
    let expectedSkipped = h.Skip(expected, trima.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_trima_even_basic() {
    let input = ReadFromCsvFile<TrimaData>("src/test/testdata/trend/trima_even.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: TrimaData => d.Close })
    let expected = h.Map(inputs[1], { d: TrimaData => d.Trima })

    let trima = Trima()
    trima.Period = 20
    let actual = h.RoundDigits(trima.Compute(closing), 2)
    let expectedSkipped = h.Skip(expected, trima.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
