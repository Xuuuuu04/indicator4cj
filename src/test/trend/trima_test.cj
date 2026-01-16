package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TrimaData {
    public var close: Float64 = 0.0
    public var Trima: Float64 = 0.0
}

@Test
public func test_trima_odd_basic() {
    let input = Csv<TrimaData>().readFromFile("src/test/testdata/trend/trima_odd.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { d: TrimaData => d.close })
    let expected = h.map(inputs[1], { d: TrimaData => d.Trima })

    let trima = Trima()
    trima.period = 15
    let actual = h.roundDigits(trima.compute(closing), 2)
    let expectedSkipped = h.skip(expected, trima.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_trima_even_basic() {
    let input = Csv<TrimaData>().readFromFile("src/test/testdata/trend/trima_even.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { d: TrimaData => d.close })
    let expected = h.map(inputs[1], { d: TrimaData => d.Trima })

    let trima = Trima()
    trima.period = 20
    let actual = h.roundDigits(trima.compute(closing), 2)
    let expectedSkipped = h.skip(expected, trima.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
