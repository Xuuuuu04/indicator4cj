package indicator4cj.test.helper

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class WaitableTest {
    @TestCase
    public func waitable_completes() {
        let wg = WaitGroup()
        let input = sliceToChan(ArrayList<Int64>([1, 2, 3]))

        let actual = waitable(wg, input)
        wg.wait()

        let expected = sliceToChan(ArrayList<Int64>([1, 2, 3]))
        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

