package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class MassIndexData {
    public var open: Float64 = 0.0
    public var close: Float64 = 0.0
    public var MassIndex: Float64 = 0.0
}

@Test
public func test_mass_index_basic() {
    let input = Csv<MassIndexData>().readFromFile("src/test/testdata/trend/mass_index.csv")
    let inputs = duplicate(input, 3)
    let highs = h.map(inputs[0], { row: MassIndexData => row.open })
    let lows = h.map(inputs[1], { row: MassIndexData => row.close })
    let expected = h.map(inputs[2], { row: MassIndexData => row.MassIndex })

    let mi = MassIndex()
    let actual = h.roundDigits(mi.compute(highs, lows), 2)
    let actualShifted = h.shift(actual, mi.idlePeriod(), 0.0)

    match (h.checkFloatEquals(actualShifted, expected)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
