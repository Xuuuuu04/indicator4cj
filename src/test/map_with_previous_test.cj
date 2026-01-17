package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class MapWithPreviousTest {
    @TestCase
    public func cumulative_sum() {
        let input = sliceToChan(ArrayList<Int64>([1, 2, 3, 4]))
        let expected = sliceToChan(ArrayList<Int64>([1, 3, 6, 10]))

        let actual = mapWithPrevious<Int64, Int64>(input, { prev, curr => prev + curr }, Int64(0))
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

