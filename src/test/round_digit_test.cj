package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class RoundDigitTest {
    @TestCase
    public func round_digit_basic() {
        @Expect(rounddigit(10.1234, 2), 10.12)
    }
}

