package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class AbsTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func abs_basic() {
        let input = sliceToChan(make([-10,20,-4,-5]))
        let expected = sliceToChan(make([10,20,4,5]))
        let actual = abs(input)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

