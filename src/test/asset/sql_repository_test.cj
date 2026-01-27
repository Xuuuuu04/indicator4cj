package indicator4cj.test.asset

import std.core.*
import std.unittest.*
import indicator4cj.asset.*

public class MockDialect <: SQLRepositoryDialect {
    public func createTable(): String { MockSqlCreate }
    public func dropTable(): String { MockSqlDrop }
    public func assets(): String { MockSqlAssets }
    public func getSince(): String { MockSqlGetSince }
    public func lastDate(): String { MockSqlLastDate }
    public func append(): String { MockSqlAppend }
}

@Test
public func test_sql_repository_basic() {
    try {
        let repo = SQLRepository(MockSqlDriver(), "mock://basic", MockDialect())
        repo.drop()
        repo.close()
    } catch (e: Exception) {
        fail(e.toString())
    }
}
