package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class BopData {
    public var Open: Float64 = 0.0
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var Bop: Float64 = 0.0
}

@Test
public func test_bop_basic() {
    let input = ReadFromCsvFile<BopData>("src/test/testdata/trend/bop.csv")
    let inputs = Duplicate(input, 5)
    let opening = h.Map(inputs[0], { row: BopData => row.Open })
    let high = h.Map(inputs[1], { row: BopData => row.High })
    let low = h.Map(inputs[2], { row: BopData => row.Low })
    let closing = h.Map(inputs[3], { row: BopData => row.Close })
    let expected = h.Map(inputs[4], { row: BopData => row.Bop })

    let bop = Bop()
    let actual = h.RoundDigits(bop.compute(opening, high, low, closing), 0)

    match (h.CheckFloatEquals(actual, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
