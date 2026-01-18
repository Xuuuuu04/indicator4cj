package indicator4cj.test.helper

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func test_divide_by_basic() {
    let input = ArrayList<Float64>([2.0, 4.0, 6.0, 8.0])
    let expected = ArrayList<Float64>([1.0, 2.0, 3.0, 4.0])
    let actual = divideBy(input.iterator(), 2.0)
    match (checkEquals(actual, expected.iterator())) {
        case Some(err) => fail(err)
        case None => ()
    }
}
