package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class SmmaData {
    public var Close: Float64 = 0.0
    public var Smma: Float64 = 0.0
}

@Test
public func test_smma_basic() {
    let input = ReadFromCsvFile<SmmaData>("src/test/testdata/trend/smma.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: SmmaData => d.Close })
    let expected = h.Map(inputs[1], { d: SmmaData => d.Smma })

    let smma = Smma()
    let actual = h.RoundDigits(smma.compute(closing), 2)
    let expectedSkipped = h.Skip(expected, smma.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
