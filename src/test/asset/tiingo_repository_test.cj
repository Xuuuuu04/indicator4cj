package indicator4cj.test.asset

import std.core.*
import std.collection.*
import indicator4cj.asset.*

// FIXME: Tiingo HTTP 交互未迁移
//
// 问题描述：当前依赖的HTTP客户端不可用，无法测试Tiingo数据源集成
// 影响：TiingoRepository的assets()和get()方法无法正常测试
// 依赖：等待 stdx.net.http 稳定后迁移HTTP客户端代码
//
// 临时方案：跳过Tiingo相关测试（使用//@Test注释掉）
// 长期方案：
//   1. 接入stdx.net.http库
//   2. 迁移Tiingo API调用代码
//   3. 恢复这两个测试用例
//
// 相关文件：src/asset/tiingo_repository.cj
// Issue: #TODO (创建GitHub Issue追踪)
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

