package indicator4cj.test.helper

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class CloserTest {
    @TestCase
    public func close_twice_no_throw() {
        let c = DummyCloser()
        closeAndLogError(c, "first")
        closeAndLogError(c, "second")
        @Expect(c.closedCount, 2)
    }
}

