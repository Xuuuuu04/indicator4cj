package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SkipTest {
    @TestCase
    public func skip_first_two() {
        let inputArr = ArrayList<Int64>()
        inputArr.add(2)
        inputArr.add(4)
        inputArr.add(6)
        inputArr.add(8)

        let expectedArr = ArrayList<Int64>()
        expectedArr.add(6)
        expectedArr.add(8)

        let actual = Skip(SliceToChan(inputArr), 2)
        let expected = SliceToChan(expectedArr)

        @Expect(CheckEquals(actual, expected) == None, true)
    }
}

