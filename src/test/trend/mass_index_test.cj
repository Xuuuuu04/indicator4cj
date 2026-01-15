package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class MassIndexData {
    public var Open: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var MassIndex: Float64 = 0.0
}

@Test
public func test_mass_index_basic() {
    let input = ReadFromCsvFile<MassIndexData>("src/test/testdata/trend/mass_index.csv")
    let inputs = Duplicate(input, 3)
    let highs = h.Map(inputs[0], { row: MassIndexData => row.Open })
    let lows = h.Map(inputs[1], { row: MassIndexData => row.Close })
    let expected = h.Map(inputs[2], { row: MassIndexData => row.MassIndex })

    let mi = MassIndex()
    let actual = h.RoundDigits(mi.compute(highs, lows), 2)
    let actualShifted = h.Shift(actual, mi.idlePeriod(), 0.0)

    match (h.CheckFloatEquals(actualShifted, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
