package indicator4cj.test

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class WaitableTest {
    @TestCase
    public func waitable_completes() {
        let wg = WaitGroup()
        let input = SliceToChan(ArrayList<Int64>([1, 2, 3]))

        let actual = Waitable(wg, input)
        wg.wait()

        let expected = SliceToChan(ArrayList<Int64>([1, 2, 3]))
        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

