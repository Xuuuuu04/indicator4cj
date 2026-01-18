package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class HighestTest {
    @TestCase
    public func highest_window() {
        let series = ArrayList<Float64>()
        series.add(1.0); series.add(3.0); series.add(2.0); series.add(5.0)
        let actual = highest(sliceToChan(series), 2)
        let expected = ArrayList<Float64>()
        expected.add(1.0)
        expected.add(3.0)
        expected.add(3.0)
        expected.add(5.0)
        @Expect(checkEquals(actual, sliceToChan(expected)) == None, true)
    }
}

