package indicator4cj.test.asset

import std.core.*
import std.unittest.*
import indicator4cj.asset.*

@Test
public func test_repository_factory_basic() {
    initRepositoryFactory()
    
    // Unknown
    let (_, err) = NewRepository("unknown", "")
    if (err.isNone()) { fail("expected error") }
    
    // Memory
    let (repoMem, err2) = NewRepository(InMemoryRepositoryBuilderName, "")
    if (err2.isSome()) { fail(err2.getOrThrow().toString()) }
    if (!(repoMem.getOrThrow() is InMemoryRepository)) { fail("not memory") }
    
    // FileSystem
    let (repoFs, err3) = NewRepository(FileSystemRepositoryBuilderName, ".")
    if (err3.isSome()) { fail(err3.getOrThrow().toString()) }
    if (!(repoFs.getOrThrow() is FileSystemRepository)) { fail("not fs") }
}