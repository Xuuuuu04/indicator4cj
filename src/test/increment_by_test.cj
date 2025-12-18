package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class IncrementByTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func increment_basic() {
        let input = SliceToChan(make([1,2,3,4]))
        let expected = SliceToChan(make([2,3,4,5]))
        let actual = IncrementBy(input, 1.0)
        @Expect(CheckEquals(actual, expected) == None, true)
    }
}

