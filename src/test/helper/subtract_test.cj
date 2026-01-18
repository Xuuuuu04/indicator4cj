package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SubtractTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func subtract_basic() {
        let ac = sliceToChan(make([2,4,6,8,10]))
        let bc = sliceToChan(make([1,2,3,4,5]))
        let expected = sliceToChan(make([1,2,3,4,5]))
        let actual = subtract(ac, bc)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

