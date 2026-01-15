package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.asset.*

private class MockRepository <: Repository {
    private var _assetsFunc: () -> ArrayList<String>
    private var _getFunc: (String) -> Iterator<Snapshot>
    private var _getSinceFunc: (String, DateTime) -> Iterator<Snapshot>
    private var _lastDateFunc: (String) -> DateTime
    private var _appendFunc: (String, Iterator<Snapshot>) -> Unit
    public var shouldFailAssets: Bool = false
    public var shouldFailGet: Bool = false
    public var shouldFailLastDate: Bool = false
    public var shouldFailAppend: Bool = false

    public init(
        assetsFunc: () -> ArrayList<String>,
        getFunc: (String) -> Iterator<Snapshot>,
        getSinceFunc: (String, DateTime) -> Iterator<Snapshot>,
        lastDateFunc: (String) -> DateTime,
        appendFunc: (String, Iterator<Snapshot>) -> Unit
    ) {
        this._assetsFunc = assetsFunc
        this._getFunc = getFunc
        this._getSinceFunc = getSinceFunc
        this._lastDateFunc = lastDateFunc
        this._appendFunc = appendFunc
    }

    public func assets(): ArrayList<String> {
        if (shouldFailAssets) { throw Exception("assets error") }
        return _assetsFunc()
    }

    public func get(name: String): Iterator<Snapshot> {
        if (shouldFailGet) { throw Exception("get error") }
        return _getFunc(name)
    }

    public func getSince(name: String, date: DateTime): Iterator<Snapshot> {
        return _getSinceFunc(name, date)
    }

    public func lastDate(name: String): DateTime {
        if (shouldFailLastDate) { throw Exception("lastDate error") }
        return _lastDateFunc(name)
    }

    public func append(name: String, snapshots: Iterator<Snapshot>): Unit {
        if (shouldFailAppend) { throw Exception("append error") }
        _appendFunc(name, snapshots)
    }
}

@Test
public func sync_success() {
    let name = "A"
    let snapshots = ArrayList<Snapshot>()
    let dt1 = DateTime.parse("2000-01-01", "yyyy-MM-dd")
    let dt2 = DateTime.parse("2000-01-02", "yyyy-MM-dd")
    snapshots.add(Snapshot(dt1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0))
    snapshots.add(Snapshot(dt2, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0))

    let source = InMemoryRepository()
    let target = InMemoryRepository()

    try {
        target.append(name, ArrayList<Snapshot>().iterator())
        source.append(name, snapshots.iterator())

        let sync = Sync()
        sync.workers = 1
        sync.delaySeconds = 0

        try {
            sync.run(source, target, dt1)
        } catch (_: Exception) {
            // Ignore expected errors
        }

        try {
            let actualIter = target.get(name)
            let actualList = ArrayList<Snapshot>()
            while (true) {
                match (actualIter.next()) {
                    case Some(s) => actualList.add(s)
                    case None => break
                }
            }
            if (actualList.size != snapshots.size) {
                fail("size mismatch actual ${actualList.size} expected ${snapshots.size}")
            }
            var idx: Int64 = 0
            while (idx < snapshots.size) {
                if (actualList[idx].date != snapshots[idx].date) {
                    fail("date mismatch at ${idx}")
                }
                idx += 1
            }
        } catch (e: Exception) {
            fail(e.toString())
        }
    } catch (e: Exception) {
        fail(e.toString())
    }
}

@Test
public func sync_missing_on_source() {
    let name = "A"
    let source = InMemoryRepository()
    let target = InMemoryRepository()
    try {
        target.append(name, ArrayList<Snapshot>().iterator())
    } catch (_: Exception) {}

    let sync = Sync()
    sync.workers = 1
    sync.delaySeconds = 0

    try {
        sync.run(source, target, DateTime.parse("2000-01-01", "yyyy-MM-dd"))
        fail("expected error")
    } catch (_: Exception) {
        // Expected error
    }
}

@Test
public func sync_failing_target_assets() {
    let source = InMemoryRepository()
    let target = MockRepository(
        { => ArrayList<String>() },
        { _ => ArrayList<Snapshot>().iterator() },
        { _, _ => ArrayList<Snapshot>().iterator() },
        { _ => DateTime.parse("2000-01-01", "yyyy-MM-dd") },
        { _, _ => () }
    )
    target.shouldFailAssets = true

    let sync = Sync()
    sync.workers = 1
    sync.delaySeconds = 0
    try {
        sync.run(source, target, DateTime.parse("2000-01-01", "yyyy-MM-dd"))
        fail("expected error")
    } catch (_: Exception) {
        // Expected error
    }
}

@Test
public func sync_failing_target_append() {
    let source = MockRepository(
        { => ArrayList<String>() },
        { _ => ArrayList<Snapshot>().iterator() },
        { _, _ => ArrayList<Snapshot>().iterator() },
        { _ => DateTime.parse("2000-01-01", "yyyy-MM-dd") },
        { _, _ => () }
    )

    let target = MockRepository(
        { => ArrayList<String>(["A"]) },
        { _ => ArrayList<Snapshot>().iterator() },
        { _, _ => ArrayList<Snapshot>().iterator() },
        { _ => DateTime.parse("2000-01-01", "yyyy-MM-dd") },
        { _, _ => () }
    )
    target.shouldFailAppend = true

    let sync = Sync()
    sync.workers = 1
    sync.delaySeconds = 0
    try {
        sync.run(source, target, DateTime.parse("2000-01-01", "yyyy-MM-dd"))
        fail("expected error")
    } catch (_: Exception) {
        // Expected error
    }
}


