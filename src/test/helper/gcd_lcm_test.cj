package indicator4cj.test.helper

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*

@Test
class GcdLcmTest {
    @TestCase
    public func gcd_basic() {
        let v = [24, 16, 8]
        @Expect(gcd(v), 8)
    }

    @TestCase
    public func lcm_basic() {
        let v = [4, 6, 3]
        @Expect(lcm(v), 12)
    }
}

