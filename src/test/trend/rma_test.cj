package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class RmaData {
    public var close: Float64 = 0.0
    public var Rma: Float64 = 0.0
}

@Test
public func test_rma_basic() {
    let input = Csv<RmaData>().readFromFile("src/test/testdata/trend/rma.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { d: RmaData => d.close })
    let expected = h.map(inputs[1], { d: RmaData => d.Rma })

    let rma = Rma(15)
    let actual = h.roundDigits(rma.compute(closing), 2)
    let expectedSkipped = h.skip(expected, rma.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
