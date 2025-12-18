package indicator4cj.test

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
        let ac = SliceToChan(make([2,4,6,8,10]))
        let bc = SliceToChan(make([1,2,3,4,5]))
        let expected = SliceToChan(make([1,2,3,4,5]))
        let actual = Subtract(ac, bc)
        @Expect(CheckEquals(actual, expected) == None, true)
    }
}

