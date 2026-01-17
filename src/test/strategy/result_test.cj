package indicator4cj.test.strategy

import std.unittest.*
import indicator4cj.strategy.*

/**
 * result_test 测试Result类的功能
 */

@Test
public func result_default_creation() {
    let result = Result()
    @Expect(result.action, 0)
}

@Test
public func result_with_action() {
    let result = Result(1)
    @Expect(result.action, 1)
}

@Test
public func result_with_different_actions() {
    let r1 = Result(0)
    let r2 = Result(1)
    let r3 = Result(2)

    @Expect(r1.action, 0)
    @Expect(r2.action, 1)
    @Expect(r3.action, 2)
}
