package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class ApoData {
    public var close: Float64 = 0.0
    public var Apo: Float64 = 0.0
}

@Test
public func test_apo_basic() {
    let input = Csv<ApoData>().readFromFile("src/test/testdata/trend/apo.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { row: ApoData => row.close })
    let expected = h.map(inputs[1], { row: ApoData => row.Apo })

    let apo = Apo()
    let actual = h.roundDigits(apo.compute(closing), 2)
    let expectedSkipped = h.skip(expected, apo.slowPeriod - 1)

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
