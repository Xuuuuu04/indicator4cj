package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class HeadTest {
    @TestCase
    public func head_basic() {
        let input = [2,4,6,8]
        let expectedArr = ArrayList<Int64>()
        expectedArr.add(2)
        expectedArr.add(4)
        let actual = Head(SliceToChan(toArrayList(input)), 2)
        let expected = SliceToChan(expectedArr)
        @Expect(CheckEquals(actual, expected) == None, true)
    }

    private func toArrayList(arr: Array<Int64>): ArrayList<Int64> {
        let list = ArrayList<Int64>()
        for (v in arr) { list.add(v) }
        return list
    }
}

