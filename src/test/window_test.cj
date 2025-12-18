package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class WindowTest {
    @TestCase
    public func window_sum() {
        let series = ArrayList<Float64>()
        series.add(1.0); series.add(3.0); series.add(2.0); series.add(5.0)
        let actual = Window(SliceToChan(series), 2, { buf, _ =>
            var s = 0.0
            for (v in buf) { s += v }
            return s
        })
        let expected = ArrayList<Float64>()
        expected.add(1.0) // first window size 1
        expected.add(4.0) // 1+3
        expected.add(5.0) // 3+2
        expected.add(7.0) // 2+5
        @Expect(CheckEquals(actual, SliceToChan(expected)) == None, true)
    }
}

