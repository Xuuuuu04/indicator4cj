package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class CciData {
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var Cci: Float64 = 0.0
}

@Test
public func test_cci_basic() {
    let input = ReadFromCsvFile<CciData>("src/test/testdata/trend/cci.csv")
    let inputs = Duplicate(input, 4)
    let high = h.Map(inputs[0], { row: CciData => row.High })
    let low = h.Map(inputs[1], { row: CciData => row.Low })
    let closing = h.Map(inputs[2], { row: CciData => row.Close })
    let expected = h.Map(inputs[3], { row: CciData => row.Cci })

    let cci = Cci()
    let actual = h.RoundDigits(cci.compute(high, low, closing), 2)
    let expectedSkipped = h.Skip(expected, cci.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
