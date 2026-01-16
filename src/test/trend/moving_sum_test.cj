package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

@Test
public func test_moving_sum_basic() {
    let input: Iterator<Float64> = SliceToChan(ArrayList<Float64>([-10.0, 20.0, -4.0, -5.0, 1.0, 5.0, 8.0, 10.0, -20.0, 4.0]))
    let expected: Iterator<Float64> = SliceToChan(ArrayList<Float64>([1.0, 12.0, -3.0, 9.0, 24.0, 3.0, 2.0]))
    
    let movingSum = MovingSum()
    movingSum.period = 4
    let actual = movingSum.compute(input)

    match (h.CheckFloatEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
