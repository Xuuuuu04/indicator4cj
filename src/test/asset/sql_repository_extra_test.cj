package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.asset.*

public class MockDialectExtra <: SQLRepositoryDialect {
    public func CreateTable(): String { "" }
    public func DropTable(): String { "" }
    public func Assets(): String { "" }
    public func GetSince(): String { "" }
    public func LastDate(): String { "" }
    public func Append(): String { "" }
}

@Test
public func test_sql_repository_extended() {
    let repo = NewSQLRepository("mock", "dsn", MockDialectExtra())
    
    // 1. 测试 Append 和 Assets
    let s1 = Snapshot(DateTime.now(), 100.0, 100.0, 100.0, 100.0, 100.0, 100.0)
    let list1 = ArrayList<Snapshot>()
    list1.add(s1)
    repo.Append("TEST1", list1.iterator())
    
    let (assets, _) = repo.Assets()
    if (assets.size != 1 || assets[0] != "TEST1") { fail("Expected 1 asset TEST1") }
    
    // 2. 测试 GetSince
    let now = DateTime.now()
    let past = now.addDays(-1)
    let future = now.addDays(1)
    
    let snapshots = ArrayList<Snapshot>()
    snapshots.add(Snapshot(past, 90.0, 90.0, 90.0, 90.0, 90.0, 90.0))
    snapshots.add(Snapshot(now, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0))
    snapshots.add(Snapshot(future, 110.0, 110.0, 110.0, 110.0, 110.0, 110.0))
    repo.Append("TEST2", snapshots.iterator())
    
    let (iter, _) = repo.GetSince("TEST2", now)
    var count = 0
    while (true) {
        match (iter.next()) {
            case Some(_) => count++
            case None => break
        }
    }
    if (count != 2) { fail("Expected 2 snapshots (now and future), got ${count}") }
    
    // 3. 测试 LastDate 的错误分支
    let (_, errL) = repo.LastDate("NON_EXISTENT")
    if (errL.isNone()) { fail("Expected error for non-existent asset") }
    
    // 4. 测试 Drop
    repo.Drop()
    let (assetsEmpty, _) = repo.Assets()
    if (assetsEmpty.size != 0) { fail("Repository should be empty after Drop") }
}
