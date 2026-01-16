package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class ShiftTest {
    @TestCase
    public func shift_basic() {
        let input = sliceToChan(ArrayList<Int64>([2, 4, 6, 8]))
        let expected = sliceToChan(ArrayList<Int64>([0, 0, 0, 0, 2, 4, 6, 8]))

        let actual = shift(input, 4, Int64(0))
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

