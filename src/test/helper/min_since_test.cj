package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class MinSinceTest {
    @TestCase
    public func min_since_basic() {
        let input = sliceToChan(ArrayList<Float64>([48.0, 50.0, 50.0, 50.0, 49.0, 49.0, 51.0]))
        let expected = sliceToChan(ArrayList<Float64>([0.0, 1.0, 2.0, 2.0, 0.0, 1.0, 2.0]))
        let actual = minSince(input, 3)
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }

    @TestCase
    public func min_since_at_end() {
        let input = sliceToChan(ArrayList<Float64>([48.0, 50.0, 50.0, 50.0, 49.0, 49.0, 49.0]))
        let expected = sliceToChan(ArrayList<Float64>([0.0, 1.0, 2.0, 2.0, 0.0, 1.0, 2.0]))
        let actual = minSince(input, 3)
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }

    @TestCase
    public func min_since_from_start() {
        let input = sliceToChan(ArrayList<Float64>([1.0, 1.0, 3.0]))
        let expected = sliceToChan(ArrayList<Float64>([0.0, 1.0, 2.0]))
        let actual = minSince(input, 3)
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

