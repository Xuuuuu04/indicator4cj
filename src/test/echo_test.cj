package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class EchoTest {
    @TestCase
    public func echo_last_two() {
        let input = sliceToChan(ArrayList<Int64>([2, 4, 6, 8]))
        let expected = sliceToChan(ArrayList<Int64>([2, 4, 6, 8, 6, 8, 6, 8, 6, 8, 6, 8]))

        let actual = echo(input, 2, 4)
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

