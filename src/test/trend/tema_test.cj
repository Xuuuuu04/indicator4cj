package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class TemaData {
    public var Close: Float64 = 0.0
    public var Tema: Float64 = 0.0
}

@Test
public func test_tema_basic() {
    let input = ReadFromCsvFile<TemaData>("src/test/testdata/trend/tema.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: TemaData => d.Close })
    let expected = h.Map(inputs[1], { d: TemaData => d.Tema })

    let tema = Tema()
    let actual = h.RoundDigits(tema.compute(closing), 2)
    let expectedSkipped = h.Skip(expected, tema.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
