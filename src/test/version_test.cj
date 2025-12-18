package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.*

@Test
class Indicator4cjMetaTest {
    // 验证版本号保持与清单一致。
    @TestCase
    public func version_matches_manifest() {
        @Expect(version(), "0.1.0")
    }

    // 描述字段非空，用于基础元信息检查。
    @TestCase
    public func description_is_non_empty() {
        @Expect(description() == "", false)
    }
}

