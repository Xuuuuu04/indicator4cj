package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class LastTest {
    @TestCase
    public func last_basic() {
        let actual = last(sliceToChan(makeList([1,2,3,4,5,6,7,8,9,10])), 4)
        let expected = sliceToChan(makeList([7,8,9,10]))
        @Expect(checkEquals(actual, expected) == None, true)
    }

    @TestCase
    public func last_less_values() {
        let actual = last(sliceToChan(makeList([1,2])), 4)
        let expected = sliceToChan(makeList([1,2]))
        @Expect(checkEquals(actual, expected) == None, true)
    }

    private func makeList(arr: Array<Int64>): ArrayList<Int64> {
        let list = ArrayList<Int64>()
        for (v in arr) { list.add(v) }
        return list
    }
}

