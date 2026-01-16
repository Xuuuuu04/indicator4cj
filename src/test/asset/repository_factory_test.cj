package indicator4cj.test.asset

import std.core.*
import std.unittest.*
import indicator4cj.asset.*

@Test
public func test_repository_factory_basic() {
    initRepositoryFactory()

    // Unknown
    try {
        let _ = newRepository("unknown", "")
        fail("expected error")
    } catch (_: Exception) {
        // Expected error
    }

    // Memory
    try {
        let repoMem = newRepository(InMemoryRepositoryBuilderName, "")
        if (!(repoMem is InMemoryRepository)) { fail("not memory") }
    } catch (e: Exception) {
        fail(e.toString())
    }

    // FileSystem
    try {
        let repoFs = newRepository(FileSystemRepositoryBuilderName, ".")
        if (!(repoFs is FileSystemRepository)) { fail("not fs") }
    } catch (e: Exception) {
        fail(e.toString())
    }
}