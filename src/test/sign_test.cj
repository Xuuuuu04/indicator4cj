package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SignTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func sign_basic() {
        let input = sliceToChan(make([-10,20,-4,0]))
        let expected = sliceToChan(make([-1,1,-1,0]))
        let actual = sign(input)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

