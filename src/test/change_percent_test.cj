package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ChangePercentTest {
    private func make(list: Array<Int64>): ArrayList<Float64> {
        let out = ArrayList<Float64>()
        for (v in list) { out.add(Float64(v)) }
        return out
    }

    @TestCase
    public func change_percent_basic() {
        let input = make([1,2,5,5,8,2,1,1,3,4])
        let expected = ArrayList<Float64>()
        expected.add(400.0)
        expected.add(150.0)
        expected.add(60.0)
        expected.add(-60.0)
        expected.add(-87.5)
        expected.add(-50.0)
        expected.add(200.0)
        expected.add(300.0)

        let actual = changePercent(sliceToChan(input), 2)
        @Expect(checkEquals(actual, sliceToChan(expected)) == None, true)
    }
}

