package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SinceTest {
    @TestCase
    public func since_changes() {
        let inputArr = ArrayList<Float64>()
        inputArr.add(1.0)
        inputArr.add(1.0)
        inputArr.add(2.0)
        inputArr.add(2.0)
        inputArr.add(2.0)
        inputArr.add(3.0)

        let expected = ArrayList<Int64>()
        expected.add(0)
        expected.add(1)
        expected.add(0)
        expected.add(1)
        expected.add(2)
        expected.add(0)

        let actual = Since(SliceToChan(inputArr))
        let expectedIter = expected.iterator()
        @Expect(CheckEquals(actual, expectedIter) == None, true)
    }
}

