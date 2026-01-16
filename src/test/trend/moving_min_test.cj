package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

@Test
public func test_moving_min_basic() {
    let input: Iterator<Float64> = sliceToChan(ArrayList<Float64>([-10.0, 20.0, -4.0, -5.0, 1.0, 5.0, 8.0, 10.0, -20.0, 4.0]))
    let expected: Iterator<Float64> = sliceToChan(ArrayList<Float64>([-10.0, -5.0, -5.0, -5.0, 1.0, -20.0, -20.0]))
    
    let movingMin = MovingMin(4)
    let actual = movingMin.compute(input)

    match (h.checkFloatEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
