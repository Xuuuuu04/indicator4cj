package indicator4cj.test

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func test_drain_basic() {
    let arr = ArrayList<Int64>([2, 4, 6, 8])
    let input = arr.iterator()
    Drain(input)
    // If we reach here without hanging/crashing, it's success.
}
