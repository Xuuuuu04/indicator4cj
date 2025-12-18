package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import indicator4cj.asset.*

private class MockRepository <: Repository {
    public let assetsFunc: () -> (ArrayList<String>, Option<Exception>)
    public let getFunc: (String) -> (Iterator<Snapshot>, Option<Exception>)
    public let getSinceFunc: (String, DateTime) -> (Iterator<Snapshot>, Option<Exception>)
    public let lastDateFunc: (String) -> (Option<DateTime>, Option<Exception>)
    public let appendFunc: (String, Iterator<Snapshot>) -> Option<Exception>

    public init(
        assetsFunc: () -> (ArrayList<String>, Option<Exception>),
        getFunc: (String) -> (Iterator<Snapshot>, Option<Exception>),
        getSinceFunc: (String, DateTime) -> (Iterator<Snapshot>, Option<Exception>),
        lastDateFunc: (String) -> (Option<DateTime>, Option<Exception>),
        appendFunc: (String, Iterator<Snapshot>) -> Option<Exception>
    ) {
        this.assetsFunc = assetsFunc
        this.getFunc = getFunc
        this.getSinceFunc = getSinceFunc
        this.lastDateFunc = lastDateFunc
        this.appendFunc = appendFunc
    }

    public func Assets(): (ArrayList<String>, Option<Exception>) { return assetsFunc() }
    public func Get(name: String): (Iterator<Snapshot>, Option<Exception>) { return getFunc(name) }
    public func GetSince(name: String, date: DateTime): (Iterator<Snapshot>, Option<Exception>) { return getSinceFunc(name, date) }
    public func LastDate(name: String): (Option<DateTime>, Option<Exception>) { return lastDateFunc(name) }
    public func Append(name: String, snapshots: Iterator<Snapshot>): Option<Exception> { return appendFunc(name, snapshots) }
}

@Test
public func sync_success() {
    let name = "A"
    let snapshots = ArrayList<Snapshot>()
    let dt1 = DateTime.parse("2000-01-01", "yyyy-MM-dd")
    let dt2 = DateTime.parse("2000-01-02", "yyyy-MM-dd")
    snapshots.add(Snapshot(dt1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0))
    snapshots.add(Snapshot(dt2, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0))

    let source = NewInMemoryRepository()
    let target = NewInMemoryRepository()

    _ = target.Append(name, ArrayList<Snapshot>().iterator())
    _ = source.Append(name, snapshots.iterator())

    let sync = NewSync()
    sync.Workers = 1
    sync.DelaySeconds = 0

    match (sync.Run(source, target, dt1)) {
        case Some(err) => fail(err.toString())
        case None => ()
    }

    let (actualIter, err) = target.Get(name)
    match (err) { case Some(e) => fail(e.toString()) case None => () }

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
        if (actualList[idx].Date != snapshots[idx].Date) {
            fail("date mismatch at ${idx}")
        }
        idx += 1
    }
}

@Test
public func sync_missing_on_source() {
    let name = "A"
    let source = NewInMemoryRepository()
    let target = NewInMemoryRepository()
    _ = target.Append(name, ArrayList<Snapshot>().iterator())

    let sync = NewSync()
    sync.Workers = 1
    sync.DelaySeconds = 0

    match (sync.Run(source, target, DateTime.parse("2000-01-01", "yyyy-MM-dd"))) {
        case Some(_) => () // expect error
        case None => fail("expected error")
    }
}

@Test
public func sync_failing_target_assets() {
    let source = NewInMemoryRepository()
    let target = MockRepository(
        { => (ArrayList<String>(), Some(Exception("assets error"))) },
        { _ => (ArrayList<Snapshot>().iterator(), None) },
        { _, _ => (ArrayList<Snapshot>().iterator(), None) },
        { _ => (None<DateTime>, None) },
        { _, _ => None }
    )

    let sync = NewSync()
    match (sync.Run(source, target, DateTime.parse("2000-01-01", "yyyy-MM-dd"))) {
        case Some(_) => ()
        case None => fail("expected error")
    }
}

@Test
public func sync_failing_target_append() {
    let source = MockRepository(
        { => (ArrayList<String>(), None) },
        { _ => (ArrayList<Snapshot>().iterator(), None) },
        { _, _ => (ArrayList<Snapshot>().iterator(), None) },
        { _ => (None<DateTime>, None) },
        { _, _ => None }
    )

    let target = MockRepository(
        { => (ArrayList<String>(["A"]), None) },
        { _ => (ArrayList<Snapshot>().iterator(), None) },
        { _, _ => (ArrayList<Snapshot>().iterator(), None) },
        { _ => (Some(DateTime.parse("2000-01-01", "yyyy-MM-dd")), None) },
        { _, _ => Some(Exception("append error")) }
    )

    let sync = NewSync()
    match (sync.Run(source, target, DateTime.parse("2000-01-01", "yyyy-MM-dd"))) {
        case Some(_) => ()
        case None => fail("expected error")
    }
}


