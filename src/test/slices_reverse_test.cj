package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import indicator4cj.helper.*

@Test
class SlicesReverseTest {
    @TestCase
    public func simple_reverse() {
        let input = ArrayList<Int64>([1, 2, 3, 4])
        let expected = ArrayList<Int64>([4, 3, 2, 1])
        let actual = ArrayList<Int64>()

        SlicesReverse(input, 0, { n =>
            actual.add(n)
            return true
        })

        @Expect(actual.size, expected.size)
        for (idx in 0..actual.size) {
            @Expect(actual[idx], expected[idx])
        }
    }

    @TestCase
    public func middle_reverse() {
        let input = ArrayList<Int64>([1, 2, 3, 4])
        let expected = ArrayList<Int64>([2, 1, 4, 3])
        let actual = ArrayList<Int64>()

        SlicesReverse(input, 2, { n =>
            actual.add(n)
            return true
        })

        @Expect(actual.size, expected.size)
        for (idx in 0..actual.size) {
            @Expect(actual[idx], expected[idx])
        }
    }
}

