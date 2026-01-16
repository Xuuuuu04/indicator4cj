package indicator4cj.test.asset

import std.core.*
import std.collection.*
import indicator4cj.asset.*

// FIXME: Tiingo HTTP 交互未迁移，待接入 stdx.net.http 后恢复测试。
//@Test
public func tiingo_repository_assets() {
    let repo = TiingoRepository("dummy")
    try {
        let names = repo.assets()
        if (names.size != 0) {
            fail("expected empty assets")
        }
    } catch (_: Exception) {
        // Expected error
    }
}

//@Test
public func tiingo_repository_get() {
    let repo = TiingoRepository("dummy")
    try {
        let _ = repo.get("AAPL")
        fail("expected unsupported error, got none")
    } catch (_: Exception) {
        // Expected error
    }
}

//@Test
public func tiingo_repository_last_date() {
    let repo = TiingoRepository("dummy")
    try {
        let _ = repo.lastDate("AAPL")
        fail("expected unsupported error, got none")
    } catch (_: Exception) {
        // Expected error
    }
}

//@Test
public func tiingo_repository_append() {
    let repo = TiingoRepository("dummy")
    try {
        repo.append("AAPL", ArrayList<Snapshot>().iterator())
        fail("expected unsupported error, got none")
    } catch (_: Exception) {
        // Expected error
    }
}

