package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class CloserTest {
    @TestCase
    public func close_twice_no_throw() {
        let c = DummyCloser()
        CloseAndLogError(c, "first")
        CloseAndLogError(c, "second")
        @Expect(c.closedCount, 2)
    }
}

