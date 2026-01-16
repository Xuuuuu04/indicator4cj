package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class KeepPositivesTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func keep_positives_basic() {
        let input = sliceToChan(make([-10,20,4,-5]))
        let expected = sliceToChan(make([0,20,4,0]))
        let actual = keepPositives(input)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

