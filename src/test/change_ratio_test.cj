package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ChangeRatioTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func change_ratio_basic() {
        let input = make([1,2,5,5,8,2,1,1,3,4])
        let expected = ArrayList<Float64>()
        expected.add(4.0)
        expected.add(1.5)
        expected.add(0.6)
        expected.add(-0.6)
        expected.add(-0.875)
        expected.add(-0.5)
        expected.add(2.0)
        expected.add(3.0)

        let actual = changeRatio(sliceToChan(input), 2)
        @Expect(checkEquals(actual, sliceToChan(expected)) == None, true)
    }
}

