package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class DecrementByTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func decrement_basic() {
        let input = sliceToChan(make([1,2,3,4]))
        let expected = sliceToChan(make([0,1,2,3]))
        let actual = decrementBy(input, 1.0)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

