package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class RoundDigitsTest {
    private func make(list: Array<Float64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(v) }
        return out
    }

    @TestCase
    public func round_digits_basic() {
        let input = sliceToChan(make([10.1234, 5.678, 6.78, 8.91011]))
        let expected = sliceToChan(make([10.12, 5.68, 6.78, 8.91]))
        let actual = roundDigits(input, 2)
        @Expect(checkEquals(actual, expected) == None, true)
    }
}

