package indicator4cj.test.helper

import std.core.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func lcm_basic() {
    @Expect(lcm([4, 6]), 12)
    @Expect(lcm([3, 5]), 15)
    @Expect(lcm([8, 12]), 24)
}

@Test
public func lcm_multiple_values() {
    @Expect(lcm([4, 6, 8]), 24)
    @Expect(lcm([3, 5, 7]), 105)
}

@Test
public func lcm_with_one() {
    @Expect(lcm([1, 5]), 5)
    @Expect(lcm([10, 1]), 10)
}

@Test
public func lcm_coprime() {
    @Expect(lcm([7, 13]), 91)
    @Expect(lcm([5, 9]), 45)
}
