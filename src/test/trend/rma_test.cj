package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class RmaData {
    public var Close: Float64 = 0.0
    public var Rma: Float64 = 0.0
}

@Test
public func test_rma_basic() {
    let input = ReadFromCsvFile<RmaData>("src/test/testdata/trend/rma.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { d: RmaData => d.Close })
    let expected = h.Map(inputs[1], { d: RmaData => d.Rma })

    let rma = Rma(15)
    let actual = h.RoundDigits(rma.Compute(closing), 2)
    let expectedSkipped = h.Skip(expected, rma.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
