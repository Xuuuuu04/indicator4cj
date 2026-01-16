package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class SeqTest {
    @TestCase
    public func seq_basic() {
        let actual = Seq(2.0, 6.0, 1.0)
        let expectedArr = ArrayList<Float64>()
        expectedArr.add(2.0)
        expectedArr.add(3.0)
        expectedArr.add(4.0)
        expectedArr.add(5.0)
        @Expect(CheckEquals(actual, SliceToChan(expectedArr)) == None, true)
    }
}

