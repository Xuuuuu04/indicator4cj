package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class SmmaData {
    public var close: Float64 = 0.0
    public var Smma: Float64 = 0.0
}

@Test
public func test_smma_basic() {
    let input = Csv<SmmaData>().readFromFile("src/test/testdata/trend/smma.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { d: SmmaData => d.close })
    let expected = h.map(inputs[1], { d: SmmaData => d.Smma })

    let smma = Smma()
    let actual = h.roundDigits(smma.compute(closing), 2)
    let expectedSkipped = h.skip(expected, smma.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
