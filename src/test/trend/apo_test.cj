package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class ApoData {
    public var Close: Float64 = 0.0
    public var Apo: Float64 = 0.0
}

@Test
public func test_apo_basic() {
    let input = ReadFromCsvFile<ApoData>("src/test/testdata/trend/apo.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { row: ApoData => row.Close })
    let expected = h.Map(inputs[1], { row: ApoData => row.Apo })

    let apo = NewApo()
    let actual = h.RoundDigits(apo.Compute(closing), 2)
    let expectedSkipped = h.Skip(expected, apo.SlowPeriod - 1)

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
