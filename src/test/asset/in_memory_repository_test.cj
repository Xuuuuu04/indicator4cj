package indicator4cj.test.asset

import std.core.*
import std.collection.*
import std.time.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.asset.*

@Test
public func test_in_memory_repository_basic() {
    try {
        let repo = InMemoryRepository()

        let assets = repo.assets()
        if (assets.size != 0) { fail("not empty") }

        let name = "A"
        let snapshots = ArrayList<Snapshot>()
        let now = DateTime.now()
        snapshots.add(Snapshot(now, 1.0, 2.0, 0.5, 1.5, 1.5, 100.0))
        snapshots.add(Snapshot(now.addDays(1), 1.5, 3.0, 1.0, 2.5, 2.5, 200.0))

        repo.append(name, snapshots.iterator())

        let assets2 = repo.assets()
        if (assets2.size != 1) { fail("size ${assets2.size}") }
        if (assets2[0] != name) { fail("name ${assets2[0]}") }

        let actual = repo.get(name)

        match (CheckEquals<Snapshot>(actual, snapshots.iterator())) {
            case Some(err) => fail(err)
            case None => ()
        }
    } catch (e: Exception) {
        fail(e.toString())
    }
}