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
    let input = Csv<MlrData>().readFromFile("src/test/testdata/trend/mlr.csv")
    let inputs = duplicate(input, 3)
    let x = h.map(inputs[0], { d: MlrData => d.X })
    let y = h.map(inputs[1], { d: MlrData => d.Y })
    let expected = h.map(inputs[2], { d: MlrData => d.R })

    let mlr = Mlr(4)
    let actual = h.roundDigits(mlr.compute(x, y), 2)
    let expectedSkipped = h.skip(expected, mlr.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
