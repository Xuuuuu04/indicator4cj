package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ChangeTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func change_basic() {
        let input = make([1,2,5,5,8,2,1,1,3,4])
        let expected = make([4,3,3,-3,-7,-1,2,3])
        let actual = change(sliceToChan(input), 2)
        @Expect(checkEquals(actual, sliceToChan(expected)) == None, true)
    }
}

