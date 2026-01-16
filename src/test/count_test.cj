package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class CountTest {
    @TestCase
    public func count_matches_length() {
        let other = ArrayList<Int64>()
        other.add(1); other.add(1); other.add(1); other.add(1)
        let expected = ArrayList<Int64>()
        expected.add(1); expected.add(2); expected.add(3); expected.add(4)
        let actual = Count(1, SliceToChan(other))
        @Expect(CheckEquals(actual, SliceToChan(expected)) == None, true)
    }
}

