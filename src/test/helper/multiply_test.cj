package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class MultiplyTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func multiply_basic() {
        let ac = sliceToChan(make([1,4,2,4,2]))
        let bc = sliceToChan(make([2,1,3,2,5]))
        let expected = sliceToChan(make([2,4,6,8,10]))
        let actual = multiply(ac, bc)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

