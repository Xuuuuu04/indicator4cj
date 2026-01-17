package indicator4cj.test

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.volatility.*

class MovingStdData {
    public var close: Float64 = 0.0
    public var std: Float64 = 0.0
}

@Test
public func test_moving_std_basic() {
    let input = Csv<MovingStdData>().readFromFile("src/test/testdata/volatility/moving_std.csv")
    let inputs = duplicate(input, 2)
    let closings = h.map(inputs[0], { d: MovingStdData => d.close })
    let expected = h.map(inputs[1], { d: MovingStdData => d.std })

    let std = MovingStd(20)
    let actual = h.roundDigits(std.compute(closings), 2)
    let expectedSkipped = h.skip(expected, std.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
