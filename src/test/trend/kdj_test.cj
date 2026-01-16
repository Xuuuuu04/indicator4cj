package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class KdjData {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var K: Float64 = 0.0
    public var D: Float64 = 0.0
    public var J: Float64 = 0.0
}

@Test
public func test_kdj_basic() {
    let input = Csv<KdjData>().readFromFile("src/test/testdata/trend/kdj.csv")
    let inputs = duplicate(input, 6)
    let high = h.map(inputs[0], { row: KdjData => row.high })
    let low = h.map(inputs[1], { row: KdjData => row.low })
    let closing = h.map(inputs[2], { row: KdjData => row.close })
    let expectedK = h.map(inputs[3], { row: KdjData => row.K })
    let expectedD = h.map(inputs[4], { row: KdjData => row.D })
    let expectedJ = h.map(inputs[5], { row: KdjData => row.J })

    let kdj = Kdj()
    let (actualKRaw, actualDRaw, actualJRaw) = kdj.compute(high, low, closing)

    let actualK = h.roundDigits(actualKRaw, 2)
    let actualD = h.roundDigits(actualDRaw, 2)
    let actualJ = h.roundDigits(actualJRaw, 2)

    let actualKShifted = h.shift(actualK, kdj.idlePeriod(), 0.0)
    let actualDShifted = h.shift(actualD, kdj.idlePeriod(), 0.0)
    let actualJShifted = h.shift(actualJ, kdj.idlePeriod(), 0.0)

    match (h.checkFloatEquals(actualKShifted, expectedK)) {
        case Some(err) => fail("K: " + err.toString())
        case None => ()
    }
    match (h.checkFloatEquals(actualDShifted, expectedD)) {
        case Some(err) => fail("D: " + err.toString())
        case None => ()
    }
    match (h.checkFloatEquals(actualJShifted, expectedJ)) {
        case Some(err) => fail("J: " + err.toString())
        case None => ()
    }
}
