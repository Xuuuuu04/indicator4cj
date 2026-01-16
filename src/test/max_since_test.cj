package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class MaxSinceTest {
    @TestCase
    public func max_since_basic() {
        let input = sliceToChan(ArrayList<Float64>([48.0, 49.0, 47.0, 52.0, 52.0, 52.0, 53.0, 50.0, 55.0]))
        let expected = sliceToChan(ArrayList<Float64>([0.0, 0.0, 1.0, 0.0, 1.0, 2.0, 0.0, 1.0, 0.0]))
        let actual = maxSince(input, 3)
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }

    @TestCase
    public func max_since_at_end() {
        let input = sliceToChan(ArrayList<Float64>([48.0, 49.0, 47.0, 52.0, 52.0, 52.0, 52.0]))
        let expected = sliceToChan(ArrayList<Float64>([0.0, 0.0, 1.0, 0.0, 1.0, 2.0, 2.0]))
        let actual = maxSince(input, 3)
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

