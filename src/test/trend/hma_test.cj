package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class HmaData {
    public var close: Float64 = 0.0
    public var Hma: Float64 = 0.0
}

@Test
public func test_hma_basic() {
    let input = Csv<HmaData>().readFromFile("src/test/testdata/trend/hma.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { row: HmaData => row.close })
    let expected = h.map(inputs[1], { row: HmaData => row.Hma })

    let hma = Hma(3)

    let actual = h.roundDigits(hma.compute(closing), 2)
    let expectedAligned = h.roundDigits(h.skip(expected, hma.idlePeriod()), 2)

    match (checkEquals(actual, expectedAligned)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
