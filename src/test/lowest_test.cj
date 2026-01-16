package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class LowestTest {
    @TestCase
    public func lowest_window() {
        let series = ArrayList<Float64>()
        series.add(1.0); series.add(3.0); series.add(2.0); series.add(5.0)
        let actual = Lowest(SliceToChan(series), 2)
        let expected = ArrayList<Float64>()
        expected.add(1.0)
        expected.add(1.0)
        expected.add(2.0)
        expected.add(2.0)
        @Expect(CheckEquals(actual, SliceToChan(expected)) == None, true)
    }
}

