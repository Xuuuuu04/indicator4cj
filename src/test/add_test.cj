package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class AddTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func add_seq() {
        let ac = SliceToChan(make([1,2,3,4,5,6,7,8,9,10]))
        let bc = SliceToChan(make([1,2,3,4,5,6,7,8,9,10]))
        let expected = SliceToChan(make([2,4,6,8,10,12,14,16,18,20]))
        let actual = Add(ac, bc)
        @Expect(CheckEquals(actual, expected) == None, true)
    }
}

