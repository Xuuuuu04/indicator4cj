package indicator4cj.test.asset

import std.core.*
import std.time.*
import std.unittest.*
import indicator4cj.asset.*

private let repositoryBase = "I:/indicator4cj/indicator4cj/src/test/testdata/strategy/repository"

@Test
public func test_file_system_repository_assets() {
    let repo = FileSystemRepository(repositoryBase)
    let (assets, err) = repo.Assets()
    if (err.isSome()) { fail(err.getOrThrow().toString()) }
    
    var found = false
    for (a in assets) {
        if (a == "brk-b") {
            found = true
            break
        }
    }
    if (!found) { fail("brk-b not found in assets") }
}

@Test
public func test_file_system_repository_get() {
    let repo = FileSystemRepository(repositoryBase)
    let (snaps, err) = repo.Get("brk-b")
    if (err.isSome()) { fail(err.getOrThrow().toString()) }

    var count = 0
    while (count < 10) {
        match (snaps.next()) {
            case Some(_) => count += 1
            case None => break
        }
    }
    if (count != 10) { fail("count ${count}") }
}

@Test
public func test_file_system_repository_last_date() {
    let repo = FileSystemRepository(repositoryBase)
    let (lastDateOpt, err) = repo.LastDate("brk-b")
    if (err.isSome()) { fail(err.getOrThrow().toString()) }

    let lastDate = lastDateOpt.getOrThrow()
    let expected = DateTime.parse("2023-11-29", "yyyy-MM-dd")
    if (lastDate.toString() != expected.toString()) {
        fail("actual ${lastDate} expected ${expected}")
    }
}
