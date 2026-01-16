package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SqrtTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func sqrt_basic() {
        let input = sliceToChan(make([9,81,16,100]))
        let expected = sliceToChan(make([3,9,4,10]))
        let actual = sqrt(input)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

