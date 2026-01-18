package indicator4cj.test.helper

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class DaysBetweenTest {
    @TestCase
    public func same_day() {
        let from = SimpleDate(2024, 9, 1)
        let to = SimpleDate(2024, 9, 1)
        @Expect(daysBetween(from, to), 0)
    }

    @TestCase
    public func two_weeks() {
        let from = SimpleDate(2024, 9, 1)
        let to = SimpleDate(2024, 9, 15)
        @Expect(daysBetween(from, to), 14)
    }
}

