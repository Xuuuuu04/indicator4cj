package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class CciData {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var Cci: Float64 = 0.0
}

@Test
public func test_cci_basic() {
    let input = Csv<CciData>().readFromFile("src/test/testdata/trend/cci.csv")
    let inputs = duplicate(input, 4)
    let high = h.map(inputs[0], { row: CciData => row.high })
    let low = h.map(inputs[1], { row: CciData => row.low })
    let closing = h.map(inputs[2], { row: CciData => row.close })
    let expected = h.map(inputs[3], { row: CciData => row.Cci })

    let cci = Cci()
    let actual = h.roundDigits(cci.compute(high, low, closing), 2)
    let expectedSkipped = h.skip(expected, cci.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
