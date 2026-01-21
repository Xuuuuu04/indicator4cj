package indicator4cj.test.helper

import std.core.*
import std.unittest.*
import indicator4cj.helper.*

@Test
public func gcd_basic() {
    @Expect(gcd([48, 18]), 6)
    @Expect(gcd([12, 8]), 4)
    @Expect(gcd([100, 25]), 25)
}

@Test
public func gcd_multiple_values() {
    @Expect(gcd([48, 18, 12]), 6)
    @Expect(gcd([60, 48, 36]), 12)
}

@Test
public func gcd_with_zero() {
    @Expect(gcd([0, 5]), 5)
    @Expect(gcd([10, 0]), 10)
}

@Test
public func gcd_coprime() {
    @Expect(gcd([7, 13]), 1)
    @Expect(gcd([17, 23]), 1)
}

@Test
public func gcd_same_number() {
    @Expect(gcd([15, 15]), 15)
}
