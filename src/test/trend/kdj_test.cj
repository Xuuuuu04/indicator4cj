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
    let inputs = Duplicate(input, 6)
    let high = h.Map(inputs[0], { row: KdjData => row.high })
    let low = h.Map(inputs[1], { row: KdjData => row.low })
    let closing = h.Map(inputs[2], { row: KdjData => row.close })
    let expectedK = h.Map(inputs[3], { row: KdjData => row.K })
    let expectedD = h.Map(inputs[4], { row: KdjData => row.D })
    let expectedJ = h.Map(inputs[5], { row: KdjData => row.J })

    let kdj = Kdj()
    let (actualKRaw, actualDRaw, actualJRaw) = kdj.compute(high, low, closing)

    let actualK = h.RoundDigits(actualKRaw, 2)
    let actualD = h.RoundDigits(actualDRaw, 2)
    let actualJ = h.RoundDigits(actualJRaw, 2)

    let actualKShifted = h.Shift(actualK, kdj.idlePeriod(), 0.0)
    let actualDShifted = h.Shift(actualD, kdj.idlePeriod(), 0.0)
    let actualJShifted = h.Shift(actualJ, kdj.idlePeriod(), 0.0)

    match (h.CheckFloatEquals(actualKShifted, expectedK)) {
        case Some(err) => fail("K: " + err.toString())
        case None => ()
    }
    match (h.CheckFloatEquals(actualDShifted, expectedD)) {
        case Some(err) => fail("D: " + err.toString())
        case None => ()
    }
    match (h.CheckFloatEquals(actualJShifted, expectedJ)) {
        case Some(err) => fail("J: " + err.toString())
        case None => ()
    }
}
