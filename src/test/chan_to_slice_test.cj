package indicator4cj.test

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func test_chan_to_slice_basic() {
    let input = ArrayList<Int64>([2, 4, 6, 8])
    let actual = input.iterator()
    let back = chanToSlice<Int64>(actual)
    @Expect(back.size, 4)
    @Expect(back[0], 2)
    @Expect(back[1], 4)
    @Expect(back[2], 6)
    @Expect(back[3], 8)
}
