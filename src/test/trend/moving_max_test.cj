package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

@Test
public func test_moving_max_basic() {
    let input: Iterator<Float64> = SliceToChan(ArrayList<Float64>([-10.0, 20.0, -4.0, -5.0, 1.0, 5.0, 8.0, 10.0, -20.0, 4.0]))
    let expected: Iterator<Float64> = SliceToChan(ArrayList<Float64>([20.0, 20.0, 5.0, 8.0, 10.0, 10.0, 10.0]))
    
    let movingMax = MovingMax(4)
    let actual = movingMax.compute(input)

    match (h.CheckFloatEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
