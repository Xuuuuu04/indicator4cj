package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class RocData {
    public var close: Float64 = 0.0
    public var Roc: Float64 = 0.0
}

@Test
public func test_roc_simple() {
    let closing = ArrayList<Float64>([2.0, 4.0, 6.0, 8.0, 9.0, 7.0])
    let expected = ArrayList<Float64>([0.0, 0.0, 0.0, (8.0 - 2.0) / 2.0, (9.0 - 4.0) / 4.0, (7.0 - 6.0) / 6.0])

    let roc = Roc()
    roc.period = 3

    let actual = roc.compute(closing.iterator())
    let expectedSkipped = h.Skip(expected.iterator(), roc.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}

@Test
public func test_roc_basic() {
    let input = Csv<RocData>().readFromFile("src/test/testdata/trend/roc.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { row: RocData => row.close })
    let expected = h.Map(inputs[1], { row: RocData => row.Roc })

    let roc = Roc()
    let actual = h.RoundDigits(roc.compute(closing), 2)
    let expectedSkipped = h.Skip(expected, roc.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }
}
