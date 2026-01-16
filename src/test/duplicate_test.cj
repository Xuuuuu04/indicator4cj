package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class DuplicateTest {
    @TestCase
    public func duplicate_four_outputs() {
        let expecteds = ArrayList<Float64>()
        expecteds.add(-10.0); expecteds.add(20.0); expecteds.add(-4.0); expecteds.add(-5.0)

        let outputs = duplicate(sliceToChan(expecteds), 4)
        for (i in 0..expecteds.size) {
            let expected = expecteds[i]
            for (out in outputs) {
                match (out.next()) {
                    case Some(v) => @Expect(v, expected)
                    case None => @Expect(true, false)
                }
            }
        }
    }
}

