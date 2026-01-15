package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class MlrData {
    public var X: Float64 = 0.0
    public var Y: Float64 = 0.0
    public var R: Float64 = 0.0
}

@Test
public func test_mlr_basic() {
    let input = ReadFromCsvFile<MlrData>("src/test/testdata/trend/mlr.csv")
    let inputs = Duplicate(input, 3)
    let x = h.Map(inputs[0], { d: MlrData => d.X })
    let y = h.Map(inputs[1], { d: MlrData => d.Y })
    let expected = h.Map(inputs[2], { d: MlrData => d.R })

    let mlr = Mlr(4)
    let actual = h.RoundDigits(mlr.compute(x, y), 2)
    let expectedSkipped = h.Skip(expected, mlr.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
