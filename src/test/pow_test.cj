package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class PowTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func pow_square() {
        let input = SliceToChan(make([2,3,5,10]))
        let expected = SliceToChan(make([4,9,25,100]))
        let actual = Pow(input, 2.0)
        @Expect(CheckEquals(actual, expected) == None, true)
    }
}

