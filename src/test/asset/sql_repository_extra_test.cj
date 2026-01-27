package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.asset.*

public class MockDialectExtra <: SQLRepositoryDialect {
    public func createTable(): String { MockSqlCreate }
    public func dropTable(): String { MockSqlDrop }
    public func assets(): String { MockSqlAssets }
    public func getSince(): String { MockSqlGetSince }
    public func lastDate(): String { MockSqlLastDate }
    public func append(): String { MockSqlAppend }
}

@Test
public func test_sql_repository_extended() {
    try {
        let repo = SQLRepository(MockSqlDriver(), "mock://extended", MockDialectExtra())

        // 1. 测试 append 和 assets
        let s1 = Snapshot(DateTime.now(), 100.0, 100.0, 100.0, 100.0, 100.0, 100.0)
        let list1 = ArrayList<Snapshot>()
        list1.add(s1)
        repo.append("TEST1", list1.iterator())

        let assets = repo.assets()
        if (assets.size != 1 || assets[0] != "TEST1") { fail("Expected 1 asset TEST1") }

        // 2. 测试 getSince
        let now = DateTime.now()
        let past = now.addDays(-1)
        let future = now.addDays(1)

        let snapshots = ArrayList<Snapshot>()
        snapshots.add(Snapshot(past, 90.0, 90.0, 90.0, 90.0, 90.0, 90.0))
        snapshots.add(Snapshot(now, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0))
        snapshots.add(Snapshot(future, 110.0, 110.0, 110.0, 110.0, 110.0, 110.0))
        repo.append("TEST2", snapshots.iterator())

        let iter = repo.getSince("TEST2", now)
        var count = 0
        while (true) {
            match (iter.next()) {
                case Some(_) => count++
                case None => break
            }
        }
        if (count != 2) { fail("Expected 2 snapshots (now and future), got ${count}") }

        // 3. 测试 lastDate 返回 None
        match (repo.lastDate("NON_EXISTENT")) {
            case Some(_) => fail("Expected None for non-existent asset")
            case None => () // Expected
        }

        // 4. 测试 drop
        repo.drop()
        let assetsEmpty = repo.assets()
        if (assetsEmpty.size != 0) { fail("Repository should be empty after drop") }

        repo.close()
    } catch (e: Exception) {
        fail(e.toString())
    }
}
