package indicator4cj.test.asset

import std.core.*
import std.unittest.*
import indicator4cj.asset.*

public class MockDialect <: SQLRepositoryDialect {
    public func CreateTable(): String { "" }
    public func DropTable(): String { "" }
    public func Assets(): String { "" }
    public func GetSince(): String { "" }
    public func LastDate(): String { "" }
    public func Append(): String { "" }
}

@Test
public func test_sql_repository_basic() {
    try {
        // 验证构造函数是否能正常创建实例
        let repo = SQLRepository(MockDialect())

        // 验证基本操作是否不报错
        repo.drop()
    } catch (e: Exception) {
        fail(e.toString())
    }
}
