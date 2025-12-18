package indicator4cj.test

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.volatility.*

class MovingStdData {
    public var Close: Float64 = 0.0
    public var Std: Float64 = 0.0
}

@Test
public func test_moving_std_basic() {
    let input = ReadFromCsvFile<MovingStdData>("src/test/testdata/volatility/moving_std.csv")
    let inputs = Duplicate(input, 2)
    let closings = h.Map(inputs[0], { d: MovingStdData => d.Close })
    let expected = h.Map(inputs[1], { d: MovingStdData => d.Std })

    let std = MovingStd(20)
    let actual = h.RoundDigits(std.Compute(closings), 2)
    let expectedSkipped = h.Skip(expected, std.IdlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
