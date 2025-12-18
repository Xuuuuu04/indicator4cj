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
    // 验证工厂函数是否能正常创建实例
    let repo = NewSQLRepository("driver", "dsn", MockDialect())
    
    // 验证基本操作是否不报错
    let err = repo.Drop()
    if (err.isSome()) { fail("Drop failed") }
}
