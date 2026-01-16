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
        let input = sliceToChan(make([2,3,5,10]))
        let expected = sliceToChan(make([4,9,25,100]))
        let actual = pow(input, 2.0)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

