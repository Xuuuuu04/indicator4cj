package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TemaData {
    public var close: Float64 = 0.0
    public var Tema: Float64 = 0.0
}

@Test
public func test_tema_basic() {
    let input = Csv<TemaData>().readFromFile("src/test/testdata/trend/tema.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { d: TemaData => d.close })
    let expected = h.map(inputs[1], { d: TemaData => d.Tema })

    let tema = Tema()
    let actual = h.roundDigits(tema.compute(closing), 2)
    let expectedSkipped = h.skip(expected, tema.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
