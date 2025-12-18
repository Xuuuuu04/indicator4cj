package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class DivideTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func divide_basic() {
        let ac = SliceToChan(make([2,4,6,8,10]))
        let bc = SliceToChan(make([2,1,3,2,5]))
        let expected = SliceToChan(make([1,4,2,4,2]))
        let actual = Divide(ac, bc)
        @Expect(CheckEquals(actual, expected) == None, true)
    }
}

