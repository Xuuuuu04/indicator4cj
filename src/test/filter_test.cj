package indicator4cj.test

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func test_filter_basic() {
    let input = ArrayList<Int64>([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    let expected = ArrayList<Int64>([2, 4, 6, 8, 10])
    let actual = Filter<Int64>(input.iterator(), { n: Int64 => n % 2 == 0 })
    match (checkEquals(actual, expected.iterator())) {
        case Some(err) => fail(err)
        case None => ()
    }
}
