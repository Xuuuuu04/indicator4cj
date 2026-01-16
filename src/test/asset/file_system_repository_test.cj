package indicator4cj.test.asset

import std.core.*
import std.time.*
import std.unittest.*
import indicator4cj.asset.*

private let _repositoryBase = "I:/indicator4cj/indicator4cj/src/test/testdata/strategy/repository"

@Test
public func test_file_system_repository_assets() {
    let repo = FileSystemRepository(_repositoryBase)
    try {
        let assets = repo.assets()

        var found = false
        for (a in assets) {
            if (a == "brk-b") {
                found = true
                break
            }
        }
        if (!found) { fail("brk-b not found in assets") }
    } catch (e: Exception) {
        fail(e.toString())
    }
}

@Test
public func test_file_system_repository_get() {
    let repo = FileSystemRepository(_repositoryBase)
    try {
        let snaps = repo.get("brk-b")

        var count = 0
        while (count < 10) {
            match (snaps.next()) {
                case Some(_) => count += 1
                case None => break
            }
        }
        if (count != 10) { fail("count ${count}") }
    } catch (e: Exception) {
        fail(e.toString())
    }
}

@Test
public func test_file_system_repository_last_date() {
    let repo = FileSystemRepository(_repositoryBase)
    try {
        let lastDate = repo.lastDate("brk-b")
        let expected = DateTime.parse("2023-11-29", "yyyy-MM-dd")
        if (lastDate.toString() != expected.toString()) {
            fail("actual ${lastDate} expected ${expected}")
        }
    } catch (e: Exception) {
        fail(e.toString())
    }
}
