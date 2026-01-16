package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SkipLastTest {
    @TestCase
    public func skip_last_two() {
        let inputArr = ArrayList<Int64>()
        inputArr.add(2)
        inputArr.add(4)
        inputArr.add(6)
        inputArr.add(8)

        let expectedArr = ArrayList<Int64>()
        expectedArr.add(2)
        expectedArr.add(4)

        let actual = skipLast(sliceToChan(inputArr), 2)
        let expected = sliceToChan(expectedArr)

        @Expect(checkEquals(actual, expected) == None, true)
    }
}

